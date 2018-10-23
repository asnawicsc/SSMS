defmodule SchoolWeb.UserChannel do
  use SchoolWeb, :channel
  require IEx
  alias School.Affairs
  alias School.Affairs.Subject
  alias School.Affairs.Teacher
  alias School.Affairs.Parent
  alias School.Settings.Institution
  alias School.Settings.UserAccess
  alias School.Settings.User

  def join("user:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket |> assign(:locale, "zh")}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("add_to_class_attendance", payload, socket) do
    class = Repo.get(Class, payload["class_id"])
    student = Repo.get(School.Affairs.Student, payload["student_id"])

    attendance =
      Repo.get_by(
        School.Affairs.Attendance,
        attendance_date: Date.utc_today(),
        class_id: payload["class_id"],
        semester_id: payload["semester_id"],
        institution_id: payload["institution_id"]
      )

    student_ids = attendance.student_id |> String.split(",")

    {action, type} =
      if Enum.any?(student_ids, fn x -> x == payload["student_id"] end) do
        student_ids = List.delete(student_ids, payload["student_id"]) |> Enum.join(",")

        Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!()

        {"has been marked as absent.", "danger"}
      else
        student_ids = List.insert_at(student_ids, 0, payload["student_id"]) |> Enum.join(",")

        Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!()

        abs =
          Repo.all(
            from(
              a in Absent,
              where: a.absent_date == ^Date.utc_today() and a.student_id == ^payload["student_id"]
            )
          )

        if abs != [] do
          Repo.delete_all(
            from(
              a in Absent,
              where: a.absent_date == ^Date.utc_today() and a.student_id == ^payload["student_id"]
            )
          )
        end

        {"has been marked as attended.", "success"}
      end

    if type == "success" do
      broadcast(socket, "show_add_results_attendance", %{
        student: student.name,
        class: class.name,
        action: action,
        type: type
      })
    else
      broadcast(socket, "show_abs_results_attendance", %{
        student: student.name,
        class: class.name,
        action: action,
        type: type
      })
    end

    {:noreply, socket}
  end

  def handle_in("hw_get_classes", payload, socket) do
    map =
      payload["map"]
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    class =
      Repo.all(
        from(
          s in StudentClass,
          left_join: c in Class,
          on: c.id == s.class_id,
          group_by: [c.id],
          where:
            s.semester_id == ^map["semester_id"] and s.institute_id == ^payload["institution_id"] and
              c.institution_id == ^payload["institution_id"],
          select: %{id: c.id, name: c.name}
        )
      )

    broadcast(socket, "hw_show_classes", %{classes: class})
    {:noreply, socket}
  end

  def handle_in("show_height_weight", payload, socket) do
    std_id = payload["std_id"]
    lvl_id = payload["lvl_id"]
    student = Repo.get(Student, std_id)

    weight =
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
          hd(weight) |> String.split("-") |> List.to_tuple() |> elem(1)
        else
          nil
        end
      else
        nil
      end

    height =
      if student.height != nil do
        heights = String.split(student.height, ",")

        height_list =
          for height <- heights do
            l_id = String.split(height, "-") |> List.to_tuple() |> elem(0)

            if l_id == payload["lvl_id"] do
              height
            end
          end
          |> Enum.reject(fn x -> x == nil end)

        if height_list != [] do
          hd(height_list) |> String.split("-") |> List.to_tuple() |> elem(1)
        else
          nil
        end
      else
        nil
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

    height =
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
          Enum.join([lists, cur_height], ",")
        else
          Enum.join([payload["lvl_id"], map["height"]], "-")
        end
      end

    weight =
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
          Enum.join([lists2, cur_weight], ",")
        else
          Enum.join([payload["lvl_id"], map["weight"]], "-")
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
    institution_id = payload["inst_id"]

    id = payload["student_id"]
    user = Repo.get(School.Settings.User, payload["user_id"])
    # institution_id = user.institution_id

    user_access =
      Repo.get_by(
        School.Settings.UserAccess,
        user_id: payload["user_id"],
        institution_id: institution_id
      )

    student = Repo.get_by(School.Affairs.Student, id: id, institution_id: institution_id)
    changeset = Affairs.change_student(student)

    conn = %{
      private: %{
        plug_session: %{
          "institution_id" => user_access.institution_id,
          "user_id" => user_access.user_id
        }
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
        institution_id: institution_id,
        action: "/students/#{student.id}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_student_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_student_details_class", payload, socket) do
    institution_id = payload["inst_id"]

    id = payload["student_id"]
    user = Repo.get(School.Settings.User, payload["user_id"])
    # institution_id = user.institution_id

    user_access =
      Repo.get_by(
        School.Settings.UserAccess,
        user_id: payload["user_id"],
        institution_id: institution_id
      )

    student = Repo.get_by(School.Affairs.Student, id: id, institution_id: institution_id)
    changeset = Affairs.change_student(student)

    conn = %{
      private: %{
        plug_session: %{
          "institution_id" => user_access.institution_id,
          "user_id" => user_access.user_id
        }
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
        csrf: payload["csrf"],
        institution_id: institution_id,
        action: "/students/#{student.id}"
      )

    csrf = payload["csrf"]
    broadcast(socket, "show_student_details2", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("delete_student", payload, socket) do
    student = Affairs.get_student!(payload["student_id"])
    {:ok, _student} = Affairs.delete_student(student)

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

    teacher = Repo.get_by(Teacher, code: code, institution_id: payload["institution_id"])
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

    parent = Repo.get_by(Parent, icno: icno, institution_id: payload["institution_id"])

    changeset = Affairs.change_parent(parent)

    conn = %{private: %{plug_session: %{"institution_id" => payload["institution_id"]}}}

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

    teacher = Repo.get_by(Teacher, code: code, institution_id: payload["institution_id"])
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
            ids: s.id,
            below_satisfy: s.below_satisfy,
            count_page: s.count_page,
            import_from_library: s.import_from_library,
            member_reading_quantity: s.member_reading_quantity,
            page: s.page,
            standard_id: s.standard_id
          }
        )
      )

    project_nilam =
      if project_nilam == [] do
      else
        project_nilam |> hd
      end

    # def handle_in("nilam_setting", payload, socket) do
    #   project_nilam =
    #     Repo.all(
    #       from(
    #         s in School.Affairs.ProjectNilam,
    #         where: s.standard_id == ^payload["level"],
    #         select: %{
    #           below_satisfy: s.below_satisfy,
    #           count_page: s.count_page,
    #           import_from_library: s.import_from_library,
    #           member_reading_quantity: s.member_reading_quantity,
    #           page: s.page,
    #           standard_id: s.standard_id
    #         }
    #       )
    #     )

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

    institution_id = payload["ins_id"]

    standard_subject =
      Repo.all(
        from(
          s in School.Affairs.StandardSubject,
          left_join: i in Subject,
          on: i.id == s.subject_id,
          left_join: l in Level,
          on: l.id == s.standard_id,
          where:
            l.institution_id == ^institution_id and i.institution_id == ^institution_id and
              s.standard_id == ^payload["standard_level"] and s.institution_id == ^institution_id,
          select: %{
            year: s.year,
            semester_id: s.semester_id,
            standard_id: l.name,
            subject_id: i.description
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

    institution_id = payload["institution_id"]

    subject_test =
      Repo.all(
        from(
          s in School.Affairs.ExamMaster,
          left_join: p in School.Affairs.Exam,
          on: p.exam_master_id == s.id,
          left_join: r in School.Affairs.Subject,
          on: r.id == p.subject_id,
          where: s.level_id == ^payload["standard_level"] and s.institution_id == ^institution_id,
          select: %{
            year: s.year,
            semester_id: s.semester_id,
            standard_id: s.level_id,
            subject_id: r.description,
            name: s.name
          }
        )
      )

    # subject_test =
    #   Repo.all(
    #     from(
    #       s in School.Affairs.ExamMaster,
    #       left_join: p in School.Affairs.Exam,
    #       on: p.exam_master_id == s.id,
    #       where: s.level_id == ^payload["standard_level"],
    #       select: %{
    #         year: s.year,
    #         semester_id: s.semester_id,
    #         standard_id: s.level_id,
    #         subject_id: p.subject_id,
    #         name: s.name
    #       }
    #     )
    #   )

    broadcast(socket, "show_subject_test", %{
      standard_level: standard_level,
      subject_test: subject_test
    })

    {:noreply, socket}
  end

  def handle_in("result_grade", payload, socket) do
    standard_level = payload["standard_level"]

    institution_id = payload["inst_id"]

    grade =
      Repo.all(
        from(
          s in School.Affairs.Grade,
          where:
            s.standard_id == ^payload["standard_level"] and s.institution_id == ^institution_id,
          select: %{
            name: s.name,
            max: s.max,
            min: s.mix,
            gpa: s.gpa,
            standard_id: s.standard_id
          }
        )
      )

    # subject_test =
    #   Repo.all(
    #     from(
    #       s in School.Affairs.ExamMaster,
    #       left_join: p in School.Affairs.Exam,
    #       on: p.exam_master_id == s.id,
    #       where: s.level_id == ^payload["standard_level"],
    #       select: %{
    #         year: s.year,
    #         semester_id: s.semester_id,
    #         standard_id: s.level_id,
    #         subject_id: p.subject_id,
    #         name: s.name
    #       }
    #     )
    #   )

    broadcast(socket, "show_standard_grade", %{
      grade: grade
    })

    {:noreply, socket}
  end

  def handle_in("grade_co", payload, socket) do
    institution_id = payload["inst_id"]

    grade =
      Repo.all(
        from(
          s in School.Affairs.CoGrade,
          where: s.institution_id == ^institution_id,
          select: %{
            name: s.name,
            max: s.max,
            min: s.min,
            gpa: s.gpa
          }
        )
      )

    # subject_test =
    #   Repo.all(
    #     from(
    #       s in School.Affairs.ExamMaster,
    #       left_join: p in School.Affairs.Exam,
    #       on: p.exam_master_id == s.id,
    #       where: s.level_id == ^payload["standard_level"],
    #       select: %{
    #         year: s.year,
    #         semester_id: s.semester_id,
    #         standard_id: s.level_id,
    #         subject_id: p.subject_id,
    #         name: s.name
    #       }
    #     )
    #   )

    broadcast(socket, "show_grade_co", %{
      grade: grade
    })

    {:noreply, socket}
  end

  def handle_in("period", payload, socket) do
    standard_level = payload["standard_level"]

    all =
      Repo.all(
        from(
          s in School.Affairs.Period,
          left_join: p in School.Affairs.Class,
          on: s.class_id == p.id,
          left_join: r in School.Affairs.Subject,
          on: r.id == s.subject_id,
          left_join: e in School.Affairs.Teacher,
          on: e.id == s.teacher_id,
          where: p.level_id == ^payload["standard_level"],
          select: %{
            day: s.day,
            start_time: s.start_time,
            end_time: s.end_time,
            subject_name: r.description,
            teacher_name: e.name,
            class_name: p.name
          }
        )
      )

    period =
      for item <- all do
        start_time = item.start_time |> Time.to_string() |> String.split_at(5) |> elem(0)
        end_time = item.start_time |> Time.to_string() |> String.split_at(5) |> elem(0)

        %{
          day: item.day,
          start_time: start_time,
          end_time: end_time,
          subject_name: item.subject_name,
          teacher_name: item.teacher_name,
          class_name: item.class_name
        }
      end

    broadcast(socket, "show_period", %{standard_level: standard_level, period: period})
    {:noreply, socket}
  end

  def handle_in("std_info", payload, socket) do
    std_id = payload["std_id"]
    institute_id = payload["institution_id"]

    standard_id = Repo.get_by(School.Affairs.Level, %{id: std_id, institution_id: institute_id})

    class =
      Repo.all(
        from(
          s in School.Affairs.Class,
          where: s.institution_id == ^institute_id and s.level_id == ^standard_id.id,
          select: %{id: s.id, name: s.name}
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ClassView,
        "class_select.html",
        class: class
      )

    broadcast(socket, "show_std_info", %{html: html})

    {:noreply, socket}
  end

  def handle_in("class_info", payload, socket) do
    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})

    {all, teacher} =
      if user.role == "Admin" or user.role == "Support" do
        class_id = payload["class_id"]

        all = Repo.get_by(School.Affairs.Class, %{id: class_id})

        teacher =
          if all.teacher_id != nil do
            Repo.get_by(School.Affairs.Teacher, id: all.teacher_id)
          else
            Repo.get_by(School.Affairs.Teacher, id: 106)
          end

        {all, teacher}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        all = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})

        {all, teacher}
      end

    broadcast(socket, "show_class_info", %{
      id: all.id,
      name: all.name,
      remark: all.remarks,
      institution_id: all.institution_id,
      level_id: all.level_id,
      teacher_id: all.teacher_id,
      teacher_name: teacher.name
    })

    {:noreply, socket}
  end

  def handle_in("student_class_listing", payload, socket) do
    class_id = payload["class_id"]

    all =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: g in School.Affairs.Class,
          on: s.class_id == g.id,
          left_join: r in School.Affairs.Student,
          on: r.id == s.sudent_id,
          where: s.class_id == ^class_id,
          select: %{
            id: s.sudent_id,
            chinese_name: r.chinese_name,
            name: r.name,
            sex: r.sex,
            dob: r.dob,
            pob: r.pob,
            b_cert: r.b_cert,
            religion: r.religion,
            race: r.race
          }
        )
      )
      |> Enum.with_index()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ClassView,
        "student_list.html",
        all: all,
        csrf: payload["csrf"],
        class_id: class_id
      )

    broadcast(socket, "show_student_class_listing", %{
      html: html
    })

    {:noreply, socket}
  end

  def handle_in("class_subject", payload, socket) do
    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})

    {all, class_id} =
      if user.role == "Admin" or user.role == "Support" do
        class_id = payload["class_id"]
        class = Repo.get_by(School.Affairs.Class, %{id: class_id})
        institution_id = payload["institution_id"]

        all =
          Repo.all(
            from(
              s in School.Affairs.SubjectTeachClass,
              left_join: g in School.Affairs.Subject,
              on: g.id == s.subject_id,
              left_join: r in School.Affairs.Teacher,
              on: r.id == s.teacher_id,
              where:
                s.class_id == ^class_id and s.standard_id == ^class.level_id and
                  g.institution_id == ^institution_id and r.institution_id == ^institution_id,
              select: %{
                subject_name: g.description,
                subject_code: g.code,
                teacher_name: r.name,
                teacher_code: r.code
              }
            )
          )

        {all, class_id}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})
        class_id = class.id
        institution_id = payload["institution_id"]

        all =
          Repo.all(
            from(
              s in School.Affairs.SubjectTeachClass,
              left_join: g in School.Affairs.Subject,
              on: g.id == s.subject_id,
              left_join: r in School.Affairs.Teacher,
              on: r.id == s.teacher_id,
              where:
                s.class_id == ^class_id and s.standard_id == ^class.level_id and
                  g.institution_id == ^institution_id and r.institution_id == ^institution_id,
              select: %{
                subject_name: g.description,
                subject_code: g.code,
                teacher_name: r.name,
                teacher_code: r.code
              }
            )
          )

        {all, class_id}
      end

    broadcast(socket, "show_class_subject", %{class_id: class_id, all: all})
    {:noreply, socket}
  end

  def handle_in("class_period", payload, socket) do
    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})

    {class_id, period} =
      if user.role == "Admin" or user.role == "Support" do
        class_id = payload["class_id"]

        class = School.Affairs.get_class!(class_id)

        period =
          Repo.all(
            from(
              p in School.Affairs.Period,
              left_join: r in School.Affairs.SubjectTeachClass,
              on: r.subject_id == p.subject_id,
              left_join: s in School.Affairs.Subject,
              on: s.id == r.subject_id,
              left_join: t in School.Affairs.Teacher,
              on: t.id == r.teacher_id,
              left_join: d in School.Affairs.Day,
              on: d.name == p.day,
              where: p.class_id == ^class_id and r.class_id == ^class_id,
              select: %{
                id: p.id,
                day_number: d.number,
                day_name: d.name,
                end_time: p.end_time,
                teacher_id: t.id,
                start_time: p.start_time,
                s_code: s.code
              }
            )
          )

        {class_id, period}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})
        class_id = class.id

        period =
          Repo.all(
            from(
              p in School.Affairs.Period,
              left_join: r in School.Affairs.SubjectTeachClass,
              on: r.subject_id == p.subject_id,
              left_join: s in School.Affairs.Subject,
              on: s.id == r.subject_id,
              left_join: t in School.Affairs.Teacher,
              on: t.id == r.teacher_id,
              left_join: d in School.Affairs.Day,
              on: d.name == p.day,
              where: p.class_id == ^class_id and r.class_id == ^class_id,
              select: %{
                id: p.id,
                day_number: d.number,
                day_name: d.name,
                end_time: p.end_time,
                teacher_id: t.id,
                start_time: p.start_time,
                s_code: s.code
              }
            )
          )

        {class_id, period}
      end

    all =
      for item <- period do
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
      for item <- period do
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

    broadcast(socket, "show_class_period", %{
      period: period,
      class_id: class_id,
      all2: Poison.encode!(all2)
    })

    {:noreply, socket}
  end

  def handle_in("class_student", payload, socket) do
    students =
      Repo.all(
        from(
          s in School.Affairs.Student,
          where: s.institution_id == ^payload["inst_id"],
          select: %{chinese_name: s.chinese_name, name: s.name, id: s.id},
          order_by: [s.name]
        )
      )

    # # # list of all students

    # # # list of all students in this class, in this semester using student class

    students_in =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: t in School.Affairs.Student,
          on: t.id == s.sudent_id,
          where:
            s.institute_id == ^payload["inst_id"] and s.semester_id == ^payload["semester_id"] and
              s.class_id == ^payload["class_id"],
          select: %{chinese_name: t.chinese_name, name: t.name, id: t.id}
        )
      )

    students_unassigned =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: t in School.Affairs.Student,
          on: t.id == s.sudent_id,
          where:
            s.institute_id == ^payload["inst_id"] and s.semester_id == ^payload["semester_id"],
          select: %{chinese_name: t.chinese_name, name: t.name, id: t.id}
        )
      )

    rem = students -- students_unassigned
    class = Repo.get(Class, payload["class_id"])

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ClassView,
        "students.html",
        students: rem,
        class: class,
        students_in: students_in
      )

    broadcast(socket, "show_class_student", %{html: html})
    {:noreply, socket}
  end

  def handle_in("class_student_info", payload, socket) do
    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})
    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})

    class_id =
      if user.role == "Admin" or user.role == "Support" do
        payload["class_id"]
      else
        class.id
      end

    students =
      Repo.all(
        from(
          s in Student,
          left_join: g in StudentClass,
          on: s.id == g.sudent_id,
          where: s.institution_id == ^payload["inst_id"] and g.class_id == ^class_id,
          order_by: [asc: s.name]
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ClassView,
        "student_class_info.html",
        students: students,
        csrf: payload["csrf"]
      )

    broadcast(socket, "show_student_class_info", %{html: html})
    {:noreply, socket}
  end

  def handle_in("subject_class_teach", payload, socket) do
    class_id = payload["class_id"]

    class = Repo.get_by(School.Affairs.Class, %{id: class_id})

    standard_subject =
      Repo.all(
        from(
          s in School.Affairs.StandardSubject,
          left_join: g in School.Affairs.Subject,
          on: g.id == s.subject_id,
          where: s.standard_id == ^class.level_id,
          select: %{subject_name: g.description, subject_code: g.code, subject_id: g.id, id: s.id}
        )
      )

    teacher =
      Repo.all(
        from(
          r in School.Affairs.Teacher,
          select: %{teacher_name: r.name, teacher_code: r.code, id: r.id}
        )
      )

    data =
      Repo.all(
        from(
          s in School.Affairs.SubjectTeachClass,
          left_join: g in School.Affairs.Subject,
          on: g.id == s.subject_id,
          left_join: r in School.Affairs.Teacher,
          on: r.id == s.teacher_id,
          where: s.class_id == ^class_id and s.standard_id == ^class.level_id,
          select: %{
            id: s.id,
            subject_id: s.subject_id,
            teacher_id: s.teacher_id,
            subject_name: g.description,
            subject_code: g.code,
            teacher_name: r.name,
            teacher_code: r.code
          }
        )
      )

    {html, action} =
      if data == [] do
        html =
          Phoenix.View.render_to_string(
            SchoolWeb.ClassView,
            "subject_class_teach.html",
            standard_subject: standard_subject,
            teacher: teacher,
            csrf: payload["csrf"],
            standard_id: class.level_id,
            class_id: class_id
          )

        action = "Please Select the Teacher"

        {html, action}
      else
        html =
          Phoenix.View.render_to_string(
            SchoolWeb.ClassView,
            "subject_class_teach_edit.html",
            standard_subject: standard_subject,
            teacher: teacher,
            csrf: payload["csrf"],
            standard_id: class.level_id,
            class_id: class_id,
            data: data
          )

        action = "Please Edit the existing Teacher"

        {html, action}
      end

    csrf = Phoenix.Controller.get_csrf_token()

    broadcast(socket, "show_subject_class_teach", %{html: html, csrf: csrf, action: action})
    {:noreply, socket}
  end

  def handle_in("create_period", payload, socket) do
    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})
    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})

    class_id =
      if user.role == "Admin" or user.role == "Support" do
        payload["class_id"]
      else
        class.id
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ClassView,
        "create_period.html",
        class_id: class_id,
        csrf: payload["csrf"]
      )

    broadcast(socket, "show_create_period", %{html: html})
    {:noreply, socket}
  end

  def handle_in("edit_period_class", payload, socket) do
    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})
    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})

    class_id =
      if user.role == "Admin" or user.role == "Support" do
        payload["class_id"]
      else
        class.id
      end

    classes = Repo.all(from(c in Class, where: c.id == ^class_id))

    period = Repo.all(from(c in School.Affairs.Period, where: c.class_id == ^class_id))

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ClassView,
        "class_period.html",
        period: period
      )

    broadcast(socket, "show_class_edit_period", %{html: html})
    {:noreply, socket}
  end

  def handle_in("mark_sheet_class", payload, socket) do
    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})

    class_id = payload["class_id"]
    class = Repo.get_by(School.Affairs.Class, id: class_id)

    {all} =
      if user.role == "Admin" or user.role == "Support" do
        all =
          Repo.all(
            from(
              p in School.Affairs.Exam,
              left_join: g in School.Affairs.ExamMaster,
              on: g.id == p.exam_master_id,
              left_join: sb in School.Affairs.Subject,
              on: sb.id == p.subject_id,
              left_join: s in School.Affairs.Class,
              on: g.level_id == s.level_id,
              where: s.id == ^class_id,
              select: %{id: sb.id, s_code: sb.code, subject: sb.description}
            )
          )

        {all}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        all =
          Repo.all(
            from(
              p in School.Affairs.Exam,
              left_join: g in School.Affairs.ExamMaster,
              on: g.id == p.exam_master_id,
              left_join: st in School.Affairs.SubjectTeachClass,
              on: st.subject_id == p.subject_id,
              left_join: sb in School.Affairs.Subject,
              on: sb.id == p.subject_id,
              left_join: s in School.Affairs.Class,
              on: g.level_id == s.level_id,
              where:
                s.id == ^class_id and st.class_id == ^class_id and st.teacher_id == ^teacher.id,
              select: %{id: sb.id, s_code: sb.code, subject: sb.description}
            )
          )

        {all}
      end

    exam =
      Repo.all(
        from(
          e in School.Affairs.ExamMaster,
          where: e.level_id == ^class.level_id,
          select: %{id: e.id, exam_name: e.name}
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "filter.html",
        all: all,
        exam: exam,
        class_id: class_id
      )

    broadcast(socket, "show_mark_sheet", %{html: html})
    {:noreply, socket}
  end

  def handle_in("mark_fill_in", payload, socket) do
    class_id = payload["class_id"]
    subject_id = payload["subject_id"]
    exam_id = payload["exam_id"]

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          where:
            s.class_id == ^class_id and s.subject_id == ^subject_id and s.exam_id == ^exam_id,
          select: %{
            class_id: s.class_id,
            subject_id: s.subject_id,
            exam_id: s.exam_id,
            student_id: s.student_id,
            mark: s.mark
          }
        )
      )

    {html} =
      if all == [] do
        class = Affairs.get_class!(class_id)
        subject = Affairs.get_subject!(subject_id)

        verify =
          Repo.all(
            from(
              s in School.Affairs.Period,
              where: s.class_id == ^class_id and s.subject_id == ^subject_id,
              select: %{teacher_id: s.teacher_id}
            )
          )

        student =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: p in Student,
              on: p.id == s.sudent_id,
              where: s.class_id == ^class_id,
              select: %{id: p.id, student_name: p.name}
            )
          )

        {Phoenix.View.render_to_string(
           SchoolWeb.ExamView,
           "mark.html",
           student: student,
           class: class,
           subject: subject,
           exam_id: exam_id,
           csrf: payload["csrf"]
         )}
      else
        class_id = all |> Enum.map(fn x -> x.class_id end) |> Enum.uniq() |> hd
        exam_id = all |> Enum.map(fn x -> x.exam_id end) |> Enum.uniq() |> hd
        subject_id = all |> Enum.map(fn x -> x.subject_id end) |> Enum.uniq() |> hd

        class = Affairs.get_class!(class_id)
        subject = Affairs.get_subject!(subject_id)

        # all_student=Repo.all(from s in School.Affairs.StudentClass,   
        #   where: e.subject_id==^subject.id and s.class_id==^class.id and e.exam_id==^exam_id and e.student_id != s.sudent_id,
        #   select: %{
        #     name: s.sudent_id,
        #     mark: e.mark
        #     })
        t =
          Repo.all(
            from(
              i in StudentClass,
              left_join: s in Student,
              on: s.id == i.sudent_id,
              where: i.class_id == ^class.id,
              select: %{name: s.name, student_id: s.id}
            )
          )

        fi =
          for item <- t do
            a = Enum.filter(all, fn x -> x.student_id == item.student_id end)

            if a == [] do
              %{
                class_id: class_id,
                exam_id: exam_id,
                student_id: item.student_id,
                subject_id: subject_id,
                student_name: item.name,
                mark: 0
              }
            else
            end
          end
          |> Enum.filter(fn x -> x != nil end)

        csrf = Phoenix.Controller.get_csrf_token()

        {Phoenix.View.render_to_string(
           SchoolWeb.ExamView,
           "edit_mark.html",
           all: all,
           fi: fi,
           class: class,
           exam_id: exam_id,
           subject: subject,
           csrf: payload["csrf"]
         )}
      end

    broadcast(socket, "show_mark_fill_in", %{html: html})
    {:noreply, socket}
  end

  def handle_in("exam_result_class", payload, socket) do
    class_id = payload["class_id"]

    class = Repo.get_by(School.Affairs.Class, id: class_id)

    exam =
      Repo.all(
        from(
          e in School.Affairs.ExamMaster,
          where: e.level_id == ^class.level_id and e.institution_id == ^payload["institution_id"],
          select: %{id: e.id, exam_name: e.name}
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "exam_filter.html",
        exam: exam,
        class_id: class_id
      )

    broadcast(socket, "show_exam_result_class", %{html: html})
    {:noreply, socket}
  end

  def handle_in("exam_result_record", payload, socket) do
    class_id = payload["class_id"] |> String.to_integer()
    exam_id = payload["exam_id"] |> String.to_integer()
    class = Repo.get_by(School.Affairs.Class, id: class_id)
    inst_id = payload["institution_id"] |> String.to_integer()

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.class_id == ^class_id and e.exam_id == ^exam_id and k.institution_id == ^inst_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            chinese_name: s.chinese_name,
            sex: s.sex,
            level_id: k.level_id
          }
        )
      )

    level_id = hd(exam_mark).level_id

    if exam_mark != [] do
      exam_standard =
        Repo.all(
          from(
            e in School.Affairs.Exam,
            left_join: k in School.Affairs.ExamMaster,
            on: k.id == e.exam_master_id,
            left_join: p in School.Affairs.Subject,
            on: p.id == e.subject_id,
            where: e.exam_master_id == ^exam_id and k.institution_id == ^inst_id,
            select: %{
              subject_code: p.code,
              exam_name: k.name
            }
          )
        )

      all =
        for item <- exam_standard do
          exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd
          student_list = exam_mark |> Enum.map(fn x -> x.student_name end) |> Enum.uniq()
          all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

          subject_code = item.subject_code

          all =
            for item <- student_list do
              student =
                Repo.all(
                  from(
                    s in School.Affairs.Student,
                    where: s.name == ^item and s.institution_id == ^inst_id
                  )
                )
                |> hd()

              s_mark = all_mark |> Enum.filter(fn x -> x.student_name == item end)

              a =
                if s_mark != [] do
                  s_mark
                else
                  %{
                    chinese_name: student.chinese_name,
                    sex: student.sex,
                    student_name: item,
                    student_id: student.id,
                    student_mark: -1,
                    exam_name: exam_name,
                    subject_code: subject_code
                  }
                end
            end
        end
        |> List.flatten()

      exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd

      all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

      mark1 =
        for item <- all_mark do
          subject_code = item |> elem(0)

          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            grades =
              Repo.all(
                from(
                  g in School.Affairs.Grade,
                  where: g.institution_id == ^inst_id and g.standard_id == ^level_id
                )
              )

            for grade <- grades do
              if student_mark >= grade.mix and student_mark <= grade.max and student_mark != -1 do
                %{
                  student_id: data.student_id,
                  student_name: data.student_name,
                  grade: grade.name,
                  gpa: grade.gpa,
                  subject_code: data.subject_code,
                  student_mark: data.student_mark,
                  chinese_name: data.chinese_name,
                  sex: data.sex
                }
              end
            end
          end
        end
        |> List.flatten()
        |> Enum.filter(fn x -> x != nil end)

      news = mark1 |> Enum.group_by(fn x -> x.student_name end)

      z =
        for new <- news do
          total =
            new
            |> elem(1)
            |> Enum.map(fn x -> x.student_mark end)
            |> Enum.filter(fn x -> x != -1 end)
            |> Enum.sum()

          per =
            new
            |> elem(1)
            |> Enum.map(fn x -> x.student_mark end)
            |> Enum.filter(fn x -> x != -1 end)
            |> Enum.count()

          total_per = per * 100

          student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd

          chinese_name =
            new |> elem(1) |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd

          sex = new |> elem(1) |> Enum.map(fn x -> x.sex end) |> Enum.uniq() |> hd

          a = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
          b = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
          c = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
          d = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
          e = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
          f = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
          g = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

          total_gpa =
            new |> elem(1) |> Enum.map(fn x -> Decimal.to_float(x.gpa) end) |> Enum.sum()

          cgpa = (total_gpa / per) |> Float.round(2)
          total_average = (total / total_per * 100) |> Float.round(2)

          %{
            subject: new |> elem(1) |> Enum.sort_by(fn x -> x.subject_code end),
            name: new |> elem(0),
            chinese_name: chinese_name,
            sex: sex,
            student_id: student_id,
            total_mark: total,
            per: per,
            total_per: total_per,
            total_average: total_average,
            a: a,
            b: b,
            c: c,
            d: d,
            e: e,
            f: f,
            g: g,
            cgpa: cgpa
          }
        end
        |> Enum.sort_by(fn x -> x.total_mark end)
        |> Enum.reverse()
        |> Enum.with_index()

      k =
        for item <- z do
          rank = item |> elem(1)
          item = item |> elem(0)

          %{
            subject: item.subject,
            name: item.name,
            chinese_name: item.chinese_name,
            sex: item.sex,
            student_id: item.student_id,
            total_mark: item.total_mark,
            per: item.per,
            total_per: item.total_per,
            total_average: item.total_average,
            a: item.a,
            b: item.b,
            c: item.c,
            d: item.d,
            e: item.e,
            f: item.f,
            g: item.g,
            cgpa: item.cgpa,
            rank: rank + 1
          }
        end
        |> Enum.sort_by(fn x -> x.name end)
        |> Enum.with_index()

      mark = mark1 |> Enum.group_by(fn x -> x.subject_code end)

      total_student = news |> Map.keys() |> Enum.count()

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.ExamView,
          "rank.html",
          z: k,
          class: class,
          exam_name: exam_name,
          mark: mark,
          mark1: mark1,
          total_student: total_student,
          class_id: payload["class_id"],
          exam_id: payload["exam_id"],
          csrf: payload["csrf"]
        )

      broadcast(socket, "show_exam_record_class", %{html: html})
      {:noreply, socket}
    else
      broadcast(socket, "show_exam_error", %{action: "Please Insert Exam Record First"})
      {:noreply, socket}
    end
  end

  def handle_in("exam_result_standard", payload, socket) do
    exam =
      Repo.all(from(e in School.Affairs.ExamMaster, where: e.level_id == ^payload["standard_id"]))
      |> Enum.map(fn x -> %{id: x.id, exam_name: x.name} end)
      |> Enum.uniq()

    html =
      Phoenix.View.render_to_string(SchoolWeb.ExamView, "exam_standard_filter.html", exam: exam)

    broadcast(socket, "show_exam_standard_filter", %{html: html})
    {:noreply, socket}
  end

  def handle_in("exam_standard_result", payload, socket) do
    exam_id = payload["exam_standard_result_id"]
    level_id = payload["standard_id"]

    standard = Repo.get_by(School.Affairs.Level, id: level_id)

    exam_id = Repo.get_by(School.Affairs.ExamMaster, %{id: exam_id, level_id: level_id})
    inst_id = payload["institution_id"] |> String.to_integer()

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.exam_id == ^exam_id.id and k.level_id == ^level_id and k.institution_id == ^inst_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            class_id: e.class_id,
            chinese_name: s.chinese_name,
            sex: s.sex
          }
        )
      )

    if exam_mark != [] do
      exam_standard =
        Repo.all(
          from(
            e in School.Affairs.Exam,
            left_join: k in School.Affairs.ExamMaster,
            on: k.id == e.exam_master_id,
            left_join: p in School.Affairs.Subject,
            on: p.id == e.subject_id,
            where: e.exam_master_id == ^exam_id.id and k.institution_id == ^inst_id,
            select: %{
              subject_code: p.code,
              exam_name: k.name
            }
          )
        )

      all =
        for item <- exam_standard do
          exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd
          student_list = exam_mark |> Enum.map(fn x -> x.student_name end) |> Enum.uniq()
          all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

          subject_code = item.subject_code

          all =
            for item <- student_list do
              student =
                Repo.all(
                  from(
                    s in School.Affairs.Student,
                    where: s.name == ^item and s.institution_id == ^inst_id
                  )
                )
                |> hd()

              student_class = Repo.get_by(School.Affairs.StudentClass, %{sudent_id: student.id})
              s_mark = all_mark |> Enum.filter(fn x -> x.student_name == item end)

              a =
                if s_mark != [] do
                  s_mark
                else
                  %{
                    chinese_name: student.chinese_name,
                    sex: student.sex,
                    student_name: item,
                    student_id: student.id,
                    student_mark: -1,
                    exam_name: exam_name,
                    subject_code: subject_code,
                    class_id: student_class.class_id
                  }
                end
            end
        end
        |> List.flatten()

      exam_name = all |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd

      all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

      mark1 =
        for item <- all_mark do
          subject_code = item |> elem(0)

          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            grades =
              Repo.all(
                from(
                  g in School.Affairs.Grade,
                  where: g.institution_id == ^inst_id and g.standard_id == ^payload["standard_id"]
                )
              )

            for grade <- grades do
              if student_mark >= grade.mix and student_mark <= grade.max do
                %{
                  student_id: data.student_id,
                  student_name: data.student_name,
                  grade: grade.name,
                  gpa: grade.gpa,
                  subject_code: subject_code,
                  student_mark: student_mark,
                  class_id: data.class_id,
                  chinese_name: data.chinese_name,
                  sex: data.sex
                }
              end
            end
          end
        end
        |> List.flatten()
        |> Enum.filter(fn x -> x != nil end)

      news = mark1 |> Enum.group_by(fn x -> x.student_name end)

      z =
        for new <- news do
          total =
            new
            |> elem(1)
            |> Enum.map(fn x -> x.student_mark end)
            |> Enum.filter(fn x -> x != -1 end)
            |> Enum.sum()

          per =
            new
            |> elem(1)
            |> Enum.map(fn x -> x.student_mark end)
            |> Enum.filter(fn x -> x != -1 end)
            |> Enum.count()

          total_per = per * 100

          total_average = (total / total_per * 100) |> Float.round(2)

          class_id = new |> elem(1) |> Enum.map(fn x -> x.class_id end) |> Enum.uniq() |> hd
          student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd

          chinese_name =
            new |> elem(1) |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd

          sex = new |> elem(1) |> Enum.map(fn x -> x.sex end) |> Enum.uniq() |> hd

          a = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
          b = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
          c = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
          d = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
          e = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
          f = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
          g = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

          total_gpa =
            new |> elem(1) |> Enum.map(fn x -> Decimal.to_float(x.gpa) end) |> Enum.sum()

          cgpa = (total_gpa / per) |> Float.round(2)

          %{
            subject: new |> elem(1) |> Enum.sort_by(fn x -> x.subject_code end),
            name: new |> elem(0),
            chinese_name: chinese_name,
            sex: sex,
            student_id: student_id,
            total_mark: total,
            per: per,
            total_per: total_per,
            total_average: total_average,
            a: a,
            b: b,
            c: c,
            d: d,
            e: e,
            f: f,
            g: g,
            cgpa: cgpa,
            class_id: class_id
          }
        end
        |> Enum.group_by(fn x -> x.class_id end)

      g =
        for group <- z do
          a =
            group
            |> elem(1)
            |> Enum.sort_by(fn x -> x.total_mark end)
            |> Enum.reverse()
            |> Enum.with_index()

          for item <- a do
            rank = item |> elem(1)
            item = item |> elem(0)
            rank = rank + 1

            %{
              subject: item.subject,
              name: item.name,
              chinese_name: item.chinese_name,
              sex: item.sex,
              student_id: item.student_id,
              total_mark: item.total_mark,
              per: item.per,
              total_per: item.total_per,
              total_average: item.total_average,
              a: item.a,
              b: item.b,
              c: item.c,
              d: item.d,
              e: item.e,
              f: item.f,
              g: item.g,
              cgpa: item.cgpa,
              class_id: item.class_id,
              class_rank: rank
            }
          end
        end
        |> List.flatten()
        |> Enum.sort_by(fn x -> x.total_mark end)
        |> Enum.reverse()
        |> Enum.with_index()

      t =
        for item <- g do
          rank = item |> elem(1)
          item = item |> elem(0)
          rank = rank + 1

          %{
            subject: item.subject,
            name: item.name,
            chinese_name: item.chinese_name,
            sex: item.sex,
            student_id: item.student_id,
            total_mark: item.total_mark,
            per: item.per,
            total_per: item.total_per,
            total_average: item.total_average,
            a: item.a,
            b: item.b,
            c: item.c,
            d: item.d,
            e: item.e,
            f: item.f,
            g: item.g,
            cgpa: item.cgpa,
            class_id: item.class_id,
            class_rank: item.class_rank,
            all_rank: rank
          }
        end
        |> Enum.sort_by(fn x -> x.name end)
        |> Enum.with_index()

      mark = mark1 |> Enum.group_by(fn x -> x.subject_code end)

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.ExamView,
          "exam_ranking.html",
          z: t,
          exam_name: exam_name,
          mark: mark,
          mark1: mark1,
          exam_id: payload["exam_standard_result_id"],
          level_id: payload["standard_id"],
          csrf: payload["csrf"]
        )

      broadcast(socket, "show_exam_record_standard", %{html: html})
      {:noreply, socket}
    else
      broadcast(socket, "show_exam_record_standard_error", %{
        action: "Please Insert Exam Record First"
      })

      {:noreply, socket}
    end
  end

  def handle_in("exam_result_analysis_class", payload, socket) do
    class_id = payload["class_id"]
    all = Repo.get_by(School.Affairs.Class, %{id: class_id})

    exam =
      Repo.all(from(e in School.Affairs.ExamMaster, where: e.level_id == ^all.level_id))
      |> Enum.map(fn x -> %{id: x.id, exam_name: x.name} end)
      |> Enum.uniq()

    html =
      Phoenix.View.render_to_string(SchoolWeb.ExamView, "generate_mark_analyse.html", exam: exam)

    broadcast(socket, "show_exam_result_analysis_class", %{html: html})
    {:noreply, socket}
  end

  def handle_in("exam_result_analysis_id", payload, socket) do
    class_id = payload["class_id"]
    exam_id = payload["exam_id"]

    class = Repo.get_by(School.Affairs.Class, %{id: class_id})

    exam = Repo.get_by(School.Affairs.ExamMaster, %{id: exam_id})

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          left_join: p in School.Affairs.Subject,
          on: s.subject_id == p.id,
          left_join: t in School.Affairs.ExamMaster,
          on: s.exam_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          where: s.class_id == ^class_id and s.exam_id == ^exam.id,
          select: %{
            class_name: r.name,
            subject_code: p.code,
            exam_name: t.name,
            student_id: s.student_id,
            mark: s.mark
          }
        )
      )

    all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        datas = item |> elem(1)

        for data <- datas do
          student_mark = data.mark

          grades = Repo.all(from(g in School.Affairs.Grade))

          for grade <- grades do
            if student_mark >= grade.mix and student_mark <= grade.max do
              %{
                student_id: data.student_id,
                grade: grade.name,
                gpa: grade.gpa,
                subject_code: subject_code,
                student_mark: student_mark,
                class_name: data.class_name,
                exam_name: data.exam_name
              }
            end
          end
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    group = mark1 |> Enum.group_by(fn x -> x.subject_code end)

    group_subject =
      for item <- group do
        subject = item |> elem(0)

        total_student = item |> elem(1) |> Enum.count()
        a = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        lulus = a + b + c + d
        fail = e + f + g

        %{
          subject: subject,
          total_student: total_student,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          f: f,
          g: g,
          lulus: lulus,
          tak_lulus: fail
        }
      end

    a = group_subject |> Enum.map(fn x -> x.a end) |> Enum.sum()
    b = group_subject |> Enum.map(fn x -> x.b end) |> Enum.sum()
    c = group_subject |> Enum.map(fn x -> x.c end) |> Enum.sum()
    d = group_subject |> Enum.map(fn x -> x.d end) |> Enum.sum()
    e = group_subject |> Enum.map(fn x -> x.e end) |> Enum.sum()
    f = group_subject |> Enum.map(fn x -> x.f end) |> Enum.sum()
    g = group_subject |> Enum.map(fn x -> x.g end) |> Enum.sum()
    lulus = group_subject |> Enum.map(fn x -> x.lulus end) |> Enum.sum()
    tak_lulus = group_subject |> Enum.map(fn x -> x.tak_lulus end) |> Enum.sum()
    total = group_subject |> Enum.map(fn x -> x.total_student end) |> Enum.sum()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "mark_analyse_subject.html",
        a: a,
        b: b,
        c: c,
        d: d,
        e: e,
        f: f,
        g: g,
        lulus: lulus,
        tak_lulus: tak_lulus,
        total: total,
        group_subject: group_subject,
        exam: exam,
        class: class,
        class_id: class_id,
        exam_id: exam_id,
        csrf: payload["csrf"]
      )

    broadcast(socket, "show_exam_result_analysis_record", %{html: html})
    {:noreply, socket}
  end

  def handle_in("exam_result_analysis_standard", payload, socket) do
    standard_id = payload["standard_id"]

    exam =
      Repo.all(from(e in School.Affairs.ExamMaster, where: e.level_id == ^payload["standard_id"]))
      |> Enum.map(fn x -> %{id: x.id, exam_name: x.name} end)
      |> Enum.uniq()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "exam_analysis_standard_filter.html",
        exam: exam
      )

    broadcast(socket, "show_exam_result_analysis_standard", %{html: html})
    {:noreply, socket}
  end

  def handle_in("exam_result_analysis_standard2", payload, socket) do
    standard_id = payload["standard_id"]
    exam_id = payload["exam_id"]

    standard = Repo.get_by(School.Affairs.Level, %{id: standard_id})

    exam = Repo.get_by(School.Affairs.ExamMaster, %{id: exam_id})

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          left_join: p in School.Affairs.Subject,
          on: s.subject_id == p.id,
          left_join: t in School.Affairs.ExamMaster,
          on: s.exam_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          left_join: d in School.Affairs.Level,
          on: r.level_id == d.id,
          where: r.level_id == ^standard.id and s.exam_id == ^exam.id,
          select: %{
            class_name: r.name,
            subject_code: p.code,
            exam_name: t.name,
            student_id: s.student_id,
            mark: s.mark
          }
        )
      )

    all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        datas = item |> elem(1)

        for data <- datas do
          student_mark = data.mark

          grades = Repo.all(from(g in School.Affairs.Grade))

          for grade <- grades do
            if student_mark >= grade.mix and student_mark <= grade.max do
              %{
                student_id: data.student_id,
                grade: grade.name,
                gpa: grade.gpa,
                subject_code: subject_code,
                student_mark: student_mark,
                class_name: data.class_name,
                exam_name: data.exam_name
              }
            end
          end
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    group = mark1 |> Enum.group_by(fn x -> x.subject_code end)

    group_subject =
      for item <- group do
        subject = item |> elem(0)

        total_student = item |> elem(1) |> Enum.count()
        a = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        lulus = a + b + c + d
        fail = e + f + g

        %{
          subject: subject,
          total_student: total_student,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          f: f,
          g: g,
          lulus: lulus,
          tak_lulus: fail
        }
      end

    a = group_subject |> Enum.map(fn x -> x.a end) |> Enum.sum()
    b = group_subject |> Enum.map(fn x -> x.b end) |> Enum.sum()
    c = group_subject |> Enum.map(fn x -> x.c end) |> Enum.sum()
    d = group_subject |> Enum.map(fn x -> x.d end) |> Enum.sum()
    e = group_subject |> Enum.map(fn x -> x.e end) |> Enum.sum()
    f = group_subject |> Enum.map(fn x -> x.f end) |> Enum.sum()
    g = group_subject |> Enum.map(fn x -> x.g end) |> Enum.sum()
    lulus = group_subject |> Enum.map(fn x -> x.lulus end) |> Enum.sum()
    tak_lulus = group_subject |> Enum.map(fn x -> x.tak_lulus end) |> Enum.sum()
    total = group_subject |> Enum.map(fn x -> x.total_student end) |> Enum.sum()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "mark_analyse_subject_standard.html",
        a: a,
        b: b,
        c: c,
        d: d,
        e: e,
        f: f,
        g: g,
        lulus: lulus,
        tak_lulus: tak_lulus,
        total: total,
        group_subject: group_subject,
        exam: exam,
        standard: standard,
        standard_id: standard_id,
        exam_id: exam_id,
        csrf: payload["csrf"]
      )

    broadcast(socket, "show_exam_result_analysis_record_standard", %{html: html})
    {:noreply, socket}
  end

  def handle_in("cocurriculum", payload, socket) do
    csrf = payload["csrf"]
    cocurriculum = payload["cocurriculum"]
    co_year = payload["co_year"]
    co_level = payload["co_level"]
    co_semester = payload["co_semester"]
    institution_id = payload["ins_id"]

    user = Repo.get_by(School.Settings.User, %{id: payload["user_id"]})

    {students} =
      if user.role == "Admin" or user.role == "Support" do
        students =
          Repo.all(
            from(
              s in School.Affairs.StudentCocurriculum,
              left_join: a in School.Affairs.Student,
              on: s.student_id == a.id,
              left_join: j in School.Affairs.StudentClass,
              on: s.student_id == j.sudent_id,
              left_join: p in School.Affairs.CoCurriculum,
              on: s.cocurriculum_id == p.id,
              left_join: c in School.Affairs.Class,
              on: j.class_id == c.id,
              where:
                s.cocurriculum_id == ^cocurriculum and s.year == ^co_year and
                  s.semester_id == ^co_semester and s.standard_id == ^co_level and
                  a.institution_id == ^institution_id and c.institution_id == ^institution_id and
                  p.institution_id == ^institution_id,
              select: %{
                id: p.id,
                student_id: s.student_id,
                name: a.name,
                class_name: c.name,
                mark: s.mark
              }
            )
          )

        {students}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        all = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})

        students =
          Repo.all(
            from(
              s in School.Affairs.StudentCocurriculum,
              left_join: a in School.Affairs.Student,
              on: s.student_id == a.id,
              left_join: j in School.Affairs.StudentClass,
              on: s.student_id == j.sudent_id,
              left_join: p in School.Affairs.CoCurriculum,
              on: s.cocurriculum_id == p.id,
              left_join: c in School.Affairs.Class,
              on: j.class_id == c.id,
              where:
                s.cocurriculum_id == ^cocurriculum and s.year == ^co_year and
                  s.semester_id == ^co_semester and s.standard_id == ^co_level and
                  a.institution_id == ^institution_id and c.institution_id == ^institution_id and
                  p.institution_id == ^institution_id,
              select: %{
                id: p.id,
                student_id: s.student_id,
                name: a.name,
                class_name: c.name,
                mark: s.mark
              }
            )
          )

        {students}
      end

    condition = students |> Enum.map(fn x -> x.mark end) |> Enum.filter(fn x -> x != nil end)

    html =
      if condition == [] do
        Phoenix.View.render_to_string(
          SchoolWeb.CoCurriculumView,
          "assign_mark.html",
          csrf: csrf,
          students: students,
          cocurriculum: cocurriculum,
          co_year: co_year,
          co_level: co_level,
          co_semester: co_semester
        )
      else
        Phoenix.View.render_to_string(
          SchoolWeb.CoCurriculumView,
          "edit_mark.html",
          csrf: csrf,
          students: students,
          cocurriculum: cocurriculum,
          co_year: co_year,
          co_level: co_level,
          co_semester: co_semester
        )
      end

    broadcast(socket, "show_cocurriculum", %{html: html})
    {:noreply, socket}
  end

  def handle_in("report_cocurriculum", payload, socket) do
    csrf = payload["csrf"]
    cocurriculum = payload["cocurriculum"]
    co_year = payload["co_year"]
    co_level = payload["co_level"]
    co_semester = payload["co_semester"]

    students =
      Repo.all(
        from(
          s in School.Affairs.StudentCocurriculum,
          left_join: a in School.Affairs.Student,
          on: s.student_id == a.id,
          left_join: j in School.Affairs.StudentClass,
          on: s.student_id == j.sudent_id,
          left_join: p in School.Affairs.CoCurriculum,
          on: s.cocurriculum_id == p.id,
          left_join: c in School.Affairs.Class,
          on: j.class_id == c.id,
          where:
            s.cocurriculum_id == ^cocurriculum and s.year == ^co_year and
              s.semester_id == ^co_semester and s.standard_id == ^co_level,
          select: %{
            id: p.id,
            student_id: s.student_id,
            chinese_name: a.chinese_name,
            name: a.name,
            class_name: c.name,
            mark: s.mark
          }
        )
      )

    html =
      if students != [] do
        Phoenix.View.render_to_string(
          SchoolWeb.CoCurriculumView,
          "report_student_co.html",
          csrf: csrf,
          students: students,
          cocurriculum: cocurriculum,
          co_year: co_year,
          co_level: co_level,
          co_semester: co_semester
        )
      else
        "No Data inside..Please choose other."
      end

    broadcast(socket, "show_report_cocurriculum", %{html: html})
    {:noreply, socket}
  end

  def handle_in("student_comment", payload, socket) do
    csrf = payload["csrf"]
    sc_class = payload["sc_class"]
    sc_semester = payload["sc_semester"]

    comment = Affairs.list_comment()

    user = Repo.get_by(School.Settings.User, %{id: String.to_integer(payload["user_id"])})

    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})

    students =
      if user.role == "Admin" or user.role == "Support" do
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: a in School.Affairs.Student,
            on: s.sudent_id == a.id,
            left_join: b in School.Affairs.StudentComment,
            on: b.student_id == s.sudent_id,
            left_join: c in School.Affairs.Class,
            on: s.class_id == c.id,
            where: s.class_id == ^sc_class and s.semester_id == ^sc_semester,
            select: %{
              student_id: a.id,
              chinese_name: a.chinese_name,
              name: a.name,
              class_name: c.name,
              coment1: b.comment1,
              coment2: b.comment2,
              coment3: b.comment3
            }
          )
        )
      else
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: a in School.Affairs.Student,
            on: s.sudent_id == a.id,
            left_join: b in School.Affairs.StudentComment,
            on: b.student_id == s.sudent_id,
            left_join: c in School.Affairs.Class,
            on: s.class_id == c.id,
            where: s.class_id == ^class.id and s.semester_id == ^sc_semester,
            select: %{
              student_id: a.id,
              chinese_name: a.chinese_name,
              name: a.name,
              class_name: c.name,
              coment1: b.comment1,
              coment2: b.comment2,
              coment3: b.comment3
            }
          )
        )
      end

    html =
      if students != [] do
        Phoenix.View.render_to_string(
          SchoolWeb.StudentCommentView,
          "student_comments.html",
          csrf: csrf,
          students: students,
          comment: comment,
          semester_id: sc_semester,
          class_id: sc_class
        )
      else
        "No Data inside..Please choose other."
      end

    broadcast(socket, "show_student_comments", %{html: html})
    {:noreply, socket}
  end

  def handle_in("insert_into_uba", %{"i_id" => i_id, "user_id" => user_id}, socket) do
    user = School.Settings.get_user!(String.to_integer(user_id))

    institution = School.Settings.get_institution!(i_id)

    uba =
      Repo.all(
        from(
          u in School.Settings.UserAccess,
          where: u.user_id == ^user.id,
          select: u.institution_id
        )
      )

    {action} =
      if Enum.any?(uba, fn x -> x == institution.id end) do
        ub =
          Repo.get_by(
            School.Settings.UserAccess,
            institution_id: institution.id,
            user_id: user.id
          )

        School.Settings.delete_user_access(ub)

        {"removed"}
      else
        params = %{institution_id: institution.id, user_id: user.id}

        School.Settings.create_user_access(params)

        {"inserted"}
      end

    broadcast(socket, "notify_user_branch_access_changed", %{
      action: action
    })

    {:noreply, socket}
  end

  def handle_in("view_co_student", payload, socket) do
    students_co =
      Repo.all(
        from(
          s in School.Affairs.StudentCocurriculum,
          left_join: sc in School.Affairs.StudentClass,
          on: s.student_id == sc.sudent_id,
          left_join: a in School.Affairs.Student,
          on: s.student_id == a.id,
          left_join: c in School.Affairs.Class,
          on: sc.class_id == c.id,
          where:
            a.institution_id == ^payload["inst_id"] and s.cocurriculum_id == ^payload["co_id"],
          select: %{id: a.id, name: a.name, class_name: c.name}
        )
      )

    html =
      if students_co != [] do
        Phoenix.View.render_to_string(
          SchoolWeb.CoCurriculumView,
          "show_student_co.html",
          students_co: students_co
        )
      else
        "No Data inside..Please choose other."
      end

    broadcast(socket, "show_co_student", %{html: html})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
