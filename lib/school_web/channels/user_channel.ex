defmodule SchoolWeb.UserChannel do
  use SchoolWeb, :channel
  require IEx
  alias School.Affairs
  alias School.Affairs.Subject
  alias School.Affairs.Teacher
  alias School.Affairs.Parent

  def join("user:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket |> assign(:locale, "zh")}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("show_height_weight", payload, socket) do
    std_id = payload["std_id"]
    lvl_id = payload["lvl_id"]
    student = Repo.get(Student, std_id)

    if student.weight != nil do
      weights = String.split(student.weight, ",")

      weight =
        for weight <- weights do
          l_id = String.split(weight, "-") |> List.to_tuple() |> elem(0)

          if l_id == payload["lvl_id"] do
            weight
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if weight != [] do
        weight = hd(weight) |> String.split("-") |> List.to_tuple() |> elem(1)
      else
        weight = nil
      end
    else
      weight = nil
    end

    if student.height != nil do
      heights = String.split(student.height, ",")

      height =
        for height <- heights do
          l_id = String.split(height, "-") |> List.to_tuple() |> elem(0)

          if l_id == payload["lvl_id"] do
            height
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if height != [] do
        height = hd(height) |> String.split("-") |> List.to_tuple() |> elem(1)
      else
        height = nil
      end
    else
      height = nil
    end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.StudentView,
        "show_height_weight.html",
        student: student,
        height: height,
        weight: weight,
        std_id: std_id
      )

    broadcast(socket, "display_height_weight", %{html: html})
    {:noreply, socket}
  end

  def handle_in("submit_height_weight", payload, socket) do
    map =
      payload["map"]
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    student = Repo.get(Student, map["std_id"])

    if student.height == nil do
      height = Enum.join([payload["lvl_id"], map["height"]], "-")
      # weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
    else
      cur_height = Enum.join([payload["lvl_id"], map["height"]], "-")
      ex_height = String.split(student.height, ",")

      lists =
        for ex <- ex_height do
          l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

          if l_id != payload["lvl_id"] do
            ex
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if lists != [] do
        lists = Enum.join(lists, ",")
        height = Enum.join([lists, cur_height], ",")
      else
        height = Enum.join([payload["lvl_id"], map["height"]], "-")
      end
    end

    if student.weight == nil do
      weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
    else
      cur_weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
      ex_weight = String.split(student.weight, ",")

      lists2 =
        for ex <- ex_weight do
          l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

          if l_id != payload["lvl_id"] do
            ex
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if lists2 != [] do
        lists2 = Enum.join(lists2, ",")
        weight = Enum.join([lists2, cur_weight], ",")
      else
        weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
      end
    end

    Student.changeset(student, %{
      height: height,
      weight: weight
    })
    |> Repo.update()

    broadcast(socket, "updated_height_weight", %{})
    {:noreply, socket}
  end

  def handle_in("load_footer", payload, socket) do
    id = payload["inst_id"]
    inst = Repo.get(School.Settings.Institution, id)

    broadcast(socket, "show_footer", %{logo_bin: inst.logo_bin, maintain: inst.maintained_by})
    {:noreply, socket}
  end

  def handle_in("load_absent_reasons", payload, socket) do
    absent =
      Repo.all(
        from(
          a in Absent,
          where: a.absent_date == ^Date.utc_today() and a.student_id == ^payload["student_id"]
        )
      )

    if absent != [] do
      broadcast(socket, "show_reasons", %{
        student_id: hd(absent).student_id,
        reason: hd(absent).reason
      })
    end

    {:noreply, socket}
  end

  def handle_in("inquire_student_details", payload, socket) do
    id = payload["student_id"]
    user = Repo.get(School.Settings.User, payload["user_id"])
    student = Affairs.get_student!(id)
    changeset = Affairs.change_student(student)

    conn = %{
      private: %{
        plug_session: %{"institution_id" => user.institution_id, "user_id" => user.id}
      }
    }

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.StudentView,
        "form.html",
        student: student,
        guardian: student.gicno,
        father: student.ficno,
        mother: student.micno,
        changeset: changeset,
        conn: conn,
        action: "/students/#{student.id}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_student_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_subject_details", payload, socket) do
    code = payload["code"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    subject = Repo.get_by(Subject, code: code)
    changeset = Affairs.change_subject(subject)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.SubjectView,
        "form.html",
        code: code,
        changeset: changeset,
        conn: conn,
        action: "/subject/#{subject.code}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_subject_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_teacher_details", payload, socket) do
    code = payload["code"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    teacher = Repo.get_by(Teacher, code: code)
    changeset = Affairs.change_teacher(teacher)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.TeacherView,
        "form.html",
        code: code,
        changeset: changeset,
        conn: conn,
        action: "/teacher/#{teacher.code}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_teacher_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_parent_details", payload, socket) do
    icno = payload["icno"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    parent = Repo.get_by(Parent, icno: icno)

    changeset = Affairs.change_parent(parent)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ParentView,
        "form.html",
        icno: icno,
        changeset: changeset,
        conn: conn,
        action: "/parent/#{parent.icno}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_parent_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_teacher_timetable", payload, socket) do
    code = payload["code"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    teacher = Repo.get_by(Teacher, code: code)
    changeset = Affairs.change_teacher(teacher)

    school_job =
      Repo.all(
        from(
          g in School.Affairs.TeacherSchoolJob,
          left_join: s in School.Affairs.SchoolJob,
          on: g.school_job_id == s.id,
          where: g.teacher_id == ^teacher.id,
          select: %{code: s.code, description: s.description, cdesc: s.cdesc}
        )
      )

    co_curriculum_job =
      Repo.all(
        from(
          g in School.Affairs.TeacherCoCurriculumJob,
          left_join: s in School.Affairs.CoCurriculumJob,
          on: g.co_curriculum_job_id == s.id,
          where: g.teacher_id == ^teacher.id,
          select: %{code: s.code, description: s.description, cdesc: s.cdesc}
        )
      )

    hem_job =
      Repo.all(
        from(
          g in School.Affairs.TeacherHemJob,
          left_join: s in School.Affairs.HemJob,
          on: g.hem_job_id == s.id,
          where: g.teacher_id == ^teacher.id,
          select: %{code: s.code, description: s.description, cdesc: s.cdesc}
        )
      )

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    period =
      Repo.all(
        from(
          p in School.Affairs.Period,
          left_join: s in School.Affairs.Subject,
          on: s.id == p.subject_id,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          left_join: d in School.Affairs.Day,
          on: d.name == p.day,
          where: p.teacher_id == ^teacher.id,
          select: %{
            day_number: d.number,
            end_time: p.end_time,
            start_time: p.start_time,
            s_code: s.code
          }
        )
      )

    teacher_period =
      Repo.all(
        from(
          p in School.Affairs.TeacherPeriod,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          left_join: d in School.Affairs.Day,
          on: d.name == p.day,
          where: p.teacher_id == ^teacher.id,
          select: %{
            day_number: d.number,
            end_time: p.end_time,
            start_time: p.start_time,
            s_code: p.activity
          }
        )
      )

    period_all = period ++ teacher_period

    all =
      for item <- period_all do
        e = item.end_time.hour
        s = item.start_time.hour

        e =
          if e == 0 do
            12
          else
            e
          end

        s =
          if s == 0 do
            12
          else
            s
          end

        %{day_number: item.day_number, end_time: e, start_time: s, s_code: item.s_code}
      end
      |> Enum.group_by(fn x -> x.day_number end)

    all2 =
      for item <- period_all do
        e = item.end_time.hour
        s = item.start_time.hour
        sm = item.start_time.minute
        em = item.end_time.minute

        e =
          if e == 0 do
            12
          else
            e
          end

        s =
          if s == 0 do
            12
          else
            s
          end

        %{
          location: item.day_number,
          end_hour: e,
          end_minute: em,
          start_minute: sm,
          start_hour: s,
          name: item.s_code
        }
      end
      |> Enum.reject(fn x -> x == nil end)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.TeacherView,
        "teacher_time_table.html",
        code: code,
        name: teacher.name,
        school_job: school_job,
        co_curriculum_job: co_curriculum_job,
        hem_job: hem_job,
        all2: Poison.encode!(all2),
        changeset: changeset,
        conn: conn,
        action: "/teacher_timetable/#{teacher.code}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_teacher_timetable", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("nilam_setting", payload, socket) do
    project_nilam =
      Repo.all(
        from(
          s in School.Affairs.ProjectNilam,
          where: s.standard_id == ^payload["level"],
          select: %{
            below_satisfy: s.below_satisfy,
            count_page: s.count_page,
            import_from_library: s.import_from_library,
            member_reading_quantity: s.member_reading_quantity,
            page: s.page,
            standard_id: s.standard_id
          }
        )
      )

    broadcast(socket, "show_project_nilam", %{project_nilam: project_nilam})
    {:noreply, socket}
  end

  def handle_in("jauhari", payload, socket) do
    jauhari =
      Repo.all(
        from(
          s in School.Affairs.Jauhari,
          where: s.standard_id == ^payload["level"],
          select: %{prize: s.prize, min: s.min, max: s.max, standard_id: s.standard_id}
        )
      )

    broadcast(socket, "show_jauhari", %{jauhari: jauhari})
    {:noreply, socket}
  end

  def handle_in("rakan", payload, socket) do
    rakan =
      Repo.all(
        from(
          s in School.Affairs.Rakan,
          where: s.standard_id == ^payload["level"],
          select: %{prize: s.prize, min: s.min, max: s.max, standard_id: s.standard_id}
        )
      )

    broadcast(socket, "show_rakan", %{rakan: rakan})
    {:noreply, socket}
  end

  def handle_in("standard_subject", payload, socket) do
    standard_level = payload["standard_level"]

    standard_subject =
      Repo.all(
        from(
          s in School.Affairs.StandardSubject,
          where: s.standard_id == ^payload["standard_level"],
          select: %{
            year: s.year,
            semester_id: s.semester_id,
            standard_id: s.standard_id,
            subject_id: s.subject_id
          }
        )
      )

    broadcast(socket, "show_standard_subject", %{
      standard_level: standard_level,
      standard_subject: standard_subject
    })

    {:noreply, socket}
  end

  def handle_in("subject_test", payload, socket) do
    standard_level = payload["standard_level"]

    subject_test =
      Repo.all(
        from(
          s in School.Affairs.ExamMaster,
          left_join: p in School.Affairs.Exam,
          on: p.exam_master_id == s.id,
          where: s.level_id == ^payload["standard_level"],
          select: %{
            year: s.year,
            semester_id: s.semester_id,
            standard_id: s.level_id,
            subject_id: p.subject_id,
            name: s.name
          }
        )
      )

    broadcast(socket, "show_subject_test", %{
      standard_level: standard_level,
      subject_test: subject_test
    })

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
