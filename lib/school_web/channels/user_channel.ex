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

  def handle_in("ed_show_parents", payload, socket) do
    student = Repo.get(Student, payload["std_id"])

    father =
      if student.ficno != nil do
        father = Repo.get_by(Parent, icno: student.ficno)
      else
        father = nil
      end

    mother =
      if student.micno != nil do
        mother = Repo.get_by(Parent, icno: student.micno)
      else
        mother = nil
      end

    guardian =
      if student.gicno != nil do
        guardian = Repo.get_by(Parent, icno: student.gicno)
      else
        guardian = nil
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.EdisciplineView,
        "parents_list.html",
        father: father,
        mother: mother,
        guardian: guardian
      )

    broadcast(socket, "parents_details", %{
      html: html
    })

    {:noreply, socket}
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
          select: %{id: c.id, name: c.name},
          order_by: [asc: c.name]
        )
      )
      |> Enum.uniq()

    semester =
      Repo.all(
        from(
          s in Semester,
          where: s.institution_id == ^payload["institution_id"],
          select: %{id: s.id, start_date: s.start_date, end_date: s.end_date}
        )
      )

    new_semesters =
      for each <- semester do
        name = Enum.join([each.start_date, each.end_date], " - ")
        each = Map.put(each, :name, name)
        each
      end

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

    teacher =
      if teacher.is_delete == nil do
        teacher = Map.put(teacher, :is_delete, false)
      else
        teacher
      end

    changeset = Affairs.change_teacher(teacher)

    conn = %{
      private: %{plug_session: %{"institution_id" => user.institution_id, "user_id" => user.id}}
    }

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.TeacherView,
        "form.html",
        code: code,
        changeset: changeset,
        conn: conn,
        teacher: teacher,
        bin: teacher.image_bin,
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

  def handle_in("inquire_parent_child_details", payload, socket) do
    icno = payload["icno"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    parent = Repo.get_by(Parent, icno: icno, institution_id: payload["institution_id"])

    changeset = Affairs.change_parent(parent)

    student1 =
      Repo.all(
        from(
          g in School.Affairs.Student,
          left_join: s in School.Affairs.StudentClass,
          on: g.id == s.sudent_id,
          left_join: f in School.Affairs.Class,
          on: f.id == s.class_id,
          where:
            g.ficno == ^icno and g.institution_id == ^payload["institution_id"] and
              s.institute_id == ^payload["institution_id"] and
              f.institution_id == ^payload["institution_id"] and
              s.semester_id == ^payload["semester_id"],
          select: %{id: g.id, name: g.name, chinese_name: g.chinese_name, class_name: f.name}
        )
      )

    student2 =
      Repo.all(
        from(
          g in School.Affairs.Student,
          left_join: s in School.Affairs.StudentClass,
          on: g.id == s.sudent_id,
          left_join: f in School.Affairs.Class,
          on: f.id == s.class_id,
          where:
            g.micno == ^icno and g.institution_id == ^payload["institution_id"] and
              s.institute_id == ^payload["institution_id"] and
              f.institution_id == ^payload["institution_id"] and
              s.semester_id == ^payload["semester_id"],
          select: %{id: g.id, name: g.name, chinese_name: g.chinese_name, class_name: f.name}
        )
      )

    student3 =
      Repo.all(
        from(
          g in School.Affairs.Student,
          left_join: s in School.Affairs.StudentClass,
          on: g.id == s.sudent_id,
          left_join: f in School.Affairs.Class,
          on: f.id == s.class_id,
          where:
            g.gicno == ^icno and g.institution_id == ^payload["institution_id"] and
              s.institute_id == ^payload["institution_id"] and
              f.institution_id == ^payload["institution_id"] and
              s.semester_id == ^payload["semester_id"],
          select: %{id: g.id, name: g.name, chinese_name: g.chinese_name, class_name: f.name}
        )
      )

    student = student1 ++ student2 ++ student3

    conn = %{private: %{plug_session: %{"institution_id" => payload["institution_id"]}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ParentView,
        "parent_child.html",
        icno: icno,
        changeset: changeset,
        conn: conn,
        student: student |> Enum.uniq(),
        parent: parent,
        action: "/parent/#{parent.icno}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_parent_child_details", %{html: html, csrf: csrf})
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
          where: s.institution_id == ^institution_id,
          select: %{
            name: s.name,
            max: s.max,
            min: s.mix,
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

        all = Repo.get(School.Affairs.Class, payload["class_id"])

        {all, teacher}
      end

    if teacher != nil do
      broadcast(socket, "show_class_info", %{
        id: all.id,
        name: all.name,
        remark: all.remarks,
        institution_id: all.institution_id,
        level_id: all.level_id,
        teacher_id: all.teacher_id,
        teacher_name: teacher.name
      })
    else
      broadcast(socket, "show_class_info", %{
        id: all.id,
        name: all.name,
        remark: all.remarks,
        institution_id: all.institution_id,
        level_id: all.level_id,
        teacher_id: nil,
        teacher_name: "No Teacher"
      })
    end

    {:noreply, socket}
  end

  def handle_in("student_class_listing", payload, socket) do
    class_id = payload["class_id"]
    semester_id = payload["semester_id"]

    all =
      if class_id != "ALL" do
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: g in School.Affairs.Class,
            on: s.class_id == g.id,
            left_join: r in School.Affairs.Student,
            on: r.id == s.sudent_id,
            where: s.class_id == ^class_id and s.semester_id == ^semester_id,
            select: %{
              id: r.id,
              id_no: r.student_no,
              chinese_name: r.chinese_name,
              name: r.name,
              sex: r.sex,
              dob: r.dob,
              pob: r.pob,
              b_cert: r.b_cert,
              religion: r.religion,
              race: r.race
            },
            order_by: [desc: r.sex, asc: r.name]
          )
        )
        |> Enum.with_index()
      else
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: g in School.Affairs.Class,
            on: s.class_id == g.id,
            left_join: r in School.Affairs.Student,
            on: r.id == s.sudent_id,
            where: s.semester_id == ^semester_id,
            select: %{
              id: r.id,
              id_no: r.student_no,
              chinese_name: r.chinese_name,
              name: r.name,
              sex: r.sex,
              dob: r.dob,
              pob: r.pob,
              b_cert: r.b_cert,
              religion: r.religion,
              race: r.race
            },
            order_by: [desc: r.sex, asc: r.name]
          )
        )
        |> Enum.with_index()
      end

    html =
      if all != [] do
        Phoenix.View.render_to_string(
          SchoolWeb.ClassView,
          "student_list.html",
          all: all,
          csrf: payload["csrf"],
          class_id: class_id,
          semester_id: semester_id
        )
      else
        "No Student In This Class"
      end

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

        class = Repo.get(School.Affairs.Class, payload["class_id"])
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

        class = Repo.get(School.Affairs.Class, payload["class_id"])
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

    class_id =
      if user.role == "Admin" or user.role == "Support" do
        payload["class_id"]
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        class = Repo.get(School.Affairs.Class, payload["class_id"])
        class.id
      end

    students =
      Repo.all(
        from(
          s in Student,
          left_join: g in StudentClass,
          on: s.id == g.sudent_id,
          left_join: c in Class,
          on: c.id == g.class_id,
          where: s.institution_id == ^payload["inst_id"] and c.id == ^class_id,
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

  def handle_in("show_studentByClass", payload, socket) do
    class = payload["class_id"]
    semester_id = payload["semester_id"]

    all =
      if class != "Choose a class" do
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: g in School.Affairs.Class,
            on: s.class_id == g.id,
            left_join: r in School.Affairs.Student,
            on: r.id == s.sudent_id,
            where: s.class_id == ^class and s.semester_id == ^semester_id,
            select: %{
              id: r.id,
              chinese_name: r.chinese_name,
              name: r.name
            },
            order_by: [asc: r.name]
          )
        )
      else
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: g in School.Affairs.Class,
            on: s.class_id == g.id,
            left_join: r in School.Affairs.Student,
            on: r.id == s.sudent_id,
            where: s.semester_id == ^semester_id,
            select: %{
              id: r.id,
              chinese_name: r.chinese_name,
              name: r.name
            },
            order_by: [asc: r.name]
          )
        )
      end

    IO.inspect(all)

    {:reply, {:ok, %{all: all}}, socket}
  end

  def handle_in("filter_events", payload, socket) do
    sub_category = payload["sub_category"]

    all =
      if(sub_category != "Choose a Sub Category") do
        all =
          Repo.all(
            from(
              s in School.Affairs.CoCurriculum,
              where: s.sub_category == ^sub_category,
              select: %{events: s.description}
            )
          )
      else
        all =
          Repo.all(
            from(
              s in School.Affairs.CoCurriculum,
              select: %{events: s.description}
            )
          )
      end

    {:reply, {:ok, %{all: all}}, socket}
  end

  def handle_in("filter_ranks", payload, socket) do
    sub_category = payload["sub_category"]

    all =
      if(sub_category != "Choose a Sub Category") do
        all =
          Repo.all(
            from(
              s in School.Affairs.Coco_Rank,
              where: s.sub_category == ^sub_category,
              select: %{rank: s.rank}
            )
          )
      else
        all =
          Repo.all(
            from(
              s in School.Affairs.Coco_Rank,
              select: %{rank: s.rank}
            )
          )
      end

    IO.inspect(all)

    {:reply, {:ok, %{all: all}}, socket}
  end

  def handle_in(
        "add_coco_students",
        %{
          "student_id" => student_id,
          "semester_id" => semester_id,
          "coco_id" => coco_id,
          "user_id" => user_id,
          "institution_id" => institution_id,
          "category" => category,
          "sub_category" => sub_category
        },
        socket
      ) do
    coco = Affairs.get_co_curriculum!(coco_id)
    student = Affairs.get_student!(student_id)

    case Affairs.create_student_cocurriculum(%{
           cocurriculum_id: coco_id,
           semester_id: semester_id,
           student_id: student_id,
           category: category,
           sub_category: sub_category
         }) do
      {:ok, sc} ->
        students = Affairs.list_student_cocurriculum(coco_id, semester_id)

        {:reply, {:ok, %{students: students}}, socket}

      {:error, changeset} ->
        Process.sleep(500)

        ex_coco =
          Repo.get(
            School.Affairs.CoCurriculum,
            Repo.get_by(
              School.Affairs.StudentCocurriculum,
              student_id: student_id,
              semester_id: semester_id,
              category: category
            ).cocurriculum_id
          )

        {:reply,
         {:error, %{name: student.name, coco: coco.sub_category, ex_coco: ex_coco.sub_category}},
         socket}
    end
  end

  def handle_in("add_coco_achievement", payload, socket) do
    date = payload["date"]
    student_id = payload["student_id"]
    category = payload["category"]
    sub_category = payload["sub_category"]
    event_name = payload["event_name"]
    participant = payload["participant"]
    peringkat = payload["peringkat"]
    rank = payload["rank"]

    Affairs.create_student_coco_achievement(%{
      date: date,
      student_id: student_id,
      category: category,
      sub_category: sub_category,
      competition_name: event_name,
      participant_type: participant,
      peringkat: peringkat,
      rank: rank
    })

    students =
      Repo.all(
        from(
          m in School.Affairs.Student_coco_achievement,
          left_join: s in School.Affairs.Student,
          on: s.id == m.student_id,
          left_join: c in StudentClass,
          on: m.student_id == c.sudent_id,
          left_join: t in Class,
          on: t.id == c.class_id,
          select: %{
            name: s.name,
            class_name: t.name,
            ic: s.ic,
            event_name: m.competition_name,
            peringkat: m.peringkat,
            rank: m.rank,
            date: m.date
          }
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.Student_coco_achievementView,
        "report_std_coco.html",
        students: students,
        date: date,
        student_id: student_id,
        category: category,
        sub_category: sub_category,
        competition_name: event_name,
        participant_type: participant,
        peringkat: peringkat,
        rank: rank
      )

    IO.inspect(students)

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("sub_teach_class", payload, socket) do
    standard_id = payload["level_id"]

    subject =
      Repo.all(
        from(
          s in School.Affairs.SubjectTeachClass,
          left_join: m in School.Affairs.Subject,
          on: m.id == s.subject_id,
          where: s.standard_id == ^standard_id and m.institution_id == ^payload["institution_id"],
          select: %{
            level_id: s.standard_id,
            subject_id: s.subject_id,
            subject_name: m.description
          }
        )
      )
      |> Enum.uniq()

    IO.inspect(subject)

    {:reply, {:ok, %{subject: subject}}, socket}
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
        csrf: payload["csrf"],
        class_id: class_id
      )

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("filter_class", payload, socket) do
    lvl_id = payload["lvl_id"]

    class =
      if lvl_id != "ALL LEVEL" do
        class =
          Repo.all(
            from(c in Affairs.Class,
              where: c.level_id == ^lvl_id,
              select: %{class_name: c.name, class_id: c.id}
            )
          )
      else
        class = "ALL CLASS"
      end

    IO.inspect(class)

    {:reply, {:ok, %{class: class}}, socket}
  end

  def handle_in("exam_result_record", payload, socket) do
    class_id = payload["class_id"] |> String.to_integer()
    exam_id = payload["exam_id"] |> String.to_integer()
    class = Repo.get_by(School.Affairs.Class, id: class_id)
    inst_id = payload["institution_id"] |> String.to_integer()

    exam_master =
      Repo.all(
        from(
          s in School.Affairs.Exam,
          left_join: g in School.Affairs.ExamMaster,
          on: g.id == s.exam_master_id,
          where: g.id == ^exam_id
        )
      )
      |> hd()

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.Exam,
          on: e.exam_id == k.id,
          left_join: g in School.Affairs.ExamMaster,
          on: g.id == k.exam_master_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.class_id == ^class_id and g.id == ^exam_id and g.institution_id == ^inst_id and
              s.institution_id == ^inst_id and p.institution_id == ^inst_id,
          select: %{
            subject_code: p.code,
            exam_name: g.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            student_grade: e.grade,
            chinese_name: s.chinese_name,
            sex: s.sex,
            level_id: g.level_id
          }
        )
      )

    level_id = class.level_id

    exam_standard =
      Repo.all(
        from(
          e in School.Affairs.Exam,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_master_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.exam_master_id == ^exam_id and k.institution_id == ^inst_id and
              p.institution_id == ^inst_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name
          }
        )
      )

    all =
      for item <- exam_standard do
        exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq()

        exam_name =
          if exam_name != [] do
            exam_name |> hd
          else
            []
          end

        student_list = exam_mark |> Enum.map(fn x -> x.student_id end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student =
              Repo.all(
                from(
                  s in School.Affairs.Student,
                  where: s.id == ^item and s.institution_id == ^inst_id
                )
              )
              |> hd()

            s_mark = all_mark |> Enum.filter(fn x -> x.student_id == item end)

            a =
              if s_mark != [] do
                s_mark
              else
                %{
                  chinese_name: student.chinese_name,
                  sex: student.sex,
                  student_name: student.name,
                  student_id: student.id,
                  student_mark: -1,
                  student_grade: "F",
                  exam_name: exam_name,
                  subject_code: subject_code
                }
              end
          end
      end
      |> List.flatten()

    exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq()

    exam_name =
      if exam_name != [] do
        exam_name |> hd
      else
        []
      end

    all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        subject =
          Repo.get_by(School.Affairs.Subject,
            code: subject_code,
            institution_id: inst_id
          )

        if subject.with_mark != 1 do
          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            %{
              student_id: data.student_id,
              student_name: data.student_name,
              grade: data.student_grade,
              gpa: 0,
              subject_code: data.subject_code,
              student_mark: 0,
              chinese_name: data.chinese_name,
              sex: data.sex
            }
          end
        else
          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            grades =
              Repo.all(
                from(
                  g in School.Affairs.ExamGrade,
                  where:
                    g.institution_id == ^inst_id and
                      g.exam_master_id == ^exam_master.exam_master_id
                )
              )

            for grade <- grades do
              if student_mark >= grade.min and student_mark <= grade.max and student_mark != -1 do
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
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    news = mark1 |> Enum.group_by(fn x -> x.student_id end)

    subject_all =
      Repo.all(
        from(s in School.Affairs.Subject,
          where: s.institution_id == ^inst_id and s.with_mark == 1,
          select: s.code
        )
      )

    z =
      for new <- news do
        total =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.sum()

        per =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.count()

        total_per = per * 100

        student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd

        chinese_name = new |> elem(1) |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd

        name = new |> elem(1) |> Enum.map(fn x -> x.student_name end) |> Enum.uniq() |> hd

        sex = new |> elem(1) |> Enum.map(fn x -> x.sex end) |> Enum.uniq() |> hd

        a = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        total_gpa =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> Decimal.to_float(x.gpa) end)
          |> Enum.sum()

        cgpa = (total_gpa / per) |> Float.round(2)
        total_average = (total / total_per * 100) |> Float.round(2)

        %{
          subject: new |> elem(1) |> Enum.sort_by(fn x -> x.subject_code end),
          name: name,
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

    institution =
      Repo.get_by(School.Settings.Institution, %{
        id: inst_id
      })

    html =
      if exam_mark != [] do
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
            exam_id: exam_master.exam_master_id,
            csrf: payload["csrf"],
            institution: institution
          )
      else
        html = "No Data Inside"
      end

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("exam_result_standard", payload, socket) do
    exam =
      Repo.all(from(e in School.Affairs.ExamMaster, where: e.level_id == ^payload["standard_id"]))
      |> Enum.map(fn x -> %{id: x.id, exam_name: x.name} end)
      |> Enum.uniq()

    html =
      Phoenix.View.render_to_string(SchoolWeb.ExamView, "exam_standard_filter.html", exam: exam)

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("exam_standard_result", payload, socket) do
    exam_id = payload["exam_standard_result_id"]
    level_id = payload["standard_id"]

    standard = Repo.get_by(School.Affairs.Level, id: level_id)

    exam_master = Repo.get_by(School.Affairs.ExamMaster, %{id: exam_id, level_id: level_id})
    inst_id = payload["institution_id"] |> String.to_integer()

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.Exam,
          on: e.exam_id == k.id,
          left_join: g in School.Affairs.ExamMaster,
          on: g.id == k.exam_master_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            g.id == ^exam_id and g.institution_id == ^inst_id and g.level_id == ^level_id and
              s.institution_id == ^inst_id and p.institution_id == ^inst_id,
          select: %{
            subject_code: p.code,
            exam_name: g.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            student_grade: e.grade,
            chinese_name: s.chinese_name,
            sex: s.sex,
            level_id: g.level_id
          }
        )
      )

    total_classes =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: o in School.Affairs.Exam,
          on: e.exam_id == o.id,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == o.exam_master_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            o.exam_master_id == ^exam_master.id and k.level_id == ^level_id and
              k.institution_id == ^inst_id and s.institution_id == ^inst_id and
              p.institution_id == ^inst_id,
          select: %{
            class_id: e.class_id
          }
        )
      )

    total_classes_no_rep = Enum.dedup(total_classes)

    total_stud_in_class =
      for class <- total_classes_no_rep do
        total = Enum.count(total_classes, fn x -> x.class_id == class.class_id end)
        %{class_id: class.class_id, total_student: total}
      end
      |> Enum.uniq()

    exam_standard =
      Repo.all(
        from(
          e in School.Affairs.Exam,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_master_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.exam_master_id == ^exam_master.id and k.institution_id == ^inst_id and
              p.institution_id == ^inst_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name
          }
        )
      )

    all =
      for item <- exam_standard do
        exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd
        student_list = exam_mark |> Enum.map(fn x -> x.student_id end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student =
              Repo.get_by(School.Affairs.Student, %{
                id: item,
                institution_id: inst_id
              })

            student_class =
              Repo.get_by(School.Affairs.StudentClass, %{
                sudent_id: student.id,
                semester_id: exam_master.semester_id
              })

            s_mark = all_mark |> Enum.filter(fn x -> x.student_id == item end)

            a =
              if s_mark != [] do
                s_mark
              else
                %{
                  chinese_name: student.chinese_name,
                  sex: student.sex,
                  student_name: student.name,
                  student_id: student.id,
                  student_mark: -1,
                  student_grade: "F",
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

        subject =
          Repo.get_by(School.Affairs.Subject,
            code: subject_code,
            institution_id: inst_id
          )

        if subject.with_mark != 1 do
          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            student_class =
              Repo.get_by(School.Affairs.StudentClass, %{
                sudent_id: data.student_id,
                semester_id: exam_master.semester_id
              })

            %{
              student_id: data.student_id,
              student_name: data.student_name,
              grade: data.student_grade,
              gpa: 0,
              subject_code: subject_code,
              student_mark: 0,
              class_id: student_class.class_id,
              chinese_name: data.chinese_name,
              sex: data.sex
            }
          end
        else
          for data <- datas do
            student_mark = data.student_mark

            student_class =
              Repo.get_by(School.Affairs.StudentClass, %{
                sudent_id: data.student_id,
                semester_id: exam_master.semester_id
              })

            grades =
              Repo.all(
                from(
                  g in School.Affairs.ExamGrade,
                  where: g.institution_id == ^inst_id and g.exam_master_id == ^exam_master.id
                )
              )

            for grade <- grades do
              if student_mark >= grade.min and student_mark <= grade.max do
                %{
                  student_id: data.student_id,
                  student_name: data.student_name,
                  grade: grade.name,
                  gpa: grade.gpa,
                  subject_code: subject_code,
                  student_mark: student_mark,
                  class_id: student_class.class_id,
                  chinese_name: data.chinese_name,
                  sex: data.sex
                }
              end
            end
          end
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    news = mark1 |> Enum.group_by(fn x -> x.student_id end)

    subject_all =
      Repo.all(
        from(s in School.Affairs.Subject,
          where: s.institution_id == ^inst_id and s.with_mark == 1,
          select: s.code
        )
      )

    z =
      for new <- news do
        total =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.sum()

        per =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.count()

        total_per = per * 100

        total_average = (total / total_per * 100) |> Float.round(2)

        class_id = new |> elem(1) |> Enum.map(fn x -> x.class_id end) |> Enum.uniq() |> hd
        student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd

        chinese_name = new |> elem(1) |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd
        name = new |> elem(1) |> Enum.map(fn x -> x.student_name end) |> Enum.uniq() |> hd

        sex = new |> elem(1) |> Enum.map(fn x -> x.sex end) |> Enum.uniq() |> hd

        a = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        total_gpa =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> Decimal.to_float(x.gpa) end)
          |> Enum.sum()

        cgpa = (total_gpa / per) |> Float.round(2)

        %{
          subject: new |> elem(1) |> Enum.sort_by(fn x -> x.subject_code end),
          name: name,
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

    total_student = t |> Enum.count()

    institution =
      Repo.get_by(School.Settings.Institution, %{
        id: inst_id
      })

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
        csrf: payload["csrf"],
        total_student_in_class: total_stud_in_class,
        total_student: total_student,
        level: standard,
        institution: institution
      )

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("exam_result_analysis_class", payload, socket) do
    class_id = payload["class_id"]

    all =
      Repo.get_by(School.Affairs.Class, %{id: class_id, institution_id: payload["institution_id"]})

    exam =
      Repo.all(from(e in School.Affairs.ExamMaster, where: e.level_id == ^all.level_id))
      |> Enum.map(fn x -> %{id: x.id, exam_name: x.name} end)
      |> Enum.uniq()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "generate_mark_analyse.html",
        exam: exam,
        csrf: payload["csrf"]
      )

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("exam_result_analysis_id", payload, socket) do
    class_id = payload["class_id"]
    exam_id = payload["exam_id"]

    class =
      Repo.get_by(School.Affairs.Class, %{id: class_id, institution_id: payload["institution_id"]})

    exam =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam_id,
        institution_id: payload["institution_id"]
      })

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          left_join: l in School.Affairs.Exam,
          on: s.exam_id == l.id,
          left_join: t in School.Affairs.ExamMaster,
          on: l.exam_master_id == t.id,
          left_join: p in School.Affairs.Subject,
          on: s.subject_id == p.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          where: s.class_id == ^class_id and t.id == ^exam.id,
          select: %{
            class_name: r.name,
            subject_code: p.description,
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

          grades =
            Repo.all(
              from(
                g in School.Affairs.ExamGrade,
                where:
                  g.institution_id == ^payload["institution_id"] and g.exam_master_id == ^exam.id
              )
            )

          for grade <- grades do
            if student_mark >= grade.min and student_mark <= grade.max do
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
        exam_id: exam.id,
        csrf: payload["csrf"]
      )

    {:reply, {:ok, %{html: html}}, socket}
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
        exam: exam,
        csrf: payload["csrf"]
      )

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("exam_result_analysis_standard2", payload, socket) do
    standard_id = payload["standard_id"]
    exam_id = payload["exam_id"]
    IO.inspect(exam_id)

    standard =
      Repo.get_by(School.Affairs.Level, %{
        id: standard_id,
        institution_id: payload["institution_id"]
      })

    exam =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam_id,
        institution_id: payload["institution_id"]
      })

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          left_join: p in School.Affairs.Subject,
          on: s.subject_id == p.id,
          left_join: k in School.Affairs.Exam,
          on: s.exam_id == k.id,
          left_join: t in School.Affairs.ExamMaster,
          on: k.exam_master_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          left_join: d in School.Affairs.Level,
          on: r.level_id == d.id,
          where: r.level_id == ^standard.id and t.id == ^exam.id,
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

    grades =
      Repo.all(
        from(
          g in School.Affairs.ExamGrade,
          where: g.institution_id == ^payload["institution_id"] and g.exam_master_id == ^exam.id
        )
      )

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        datas = item |> elem(1)

        for data <- datas do
          student_mark = data.mark |> Decimal.to_integer()

          for grade <- grades do
            if student_mark >= grade.min && student_mark <= grade.max do
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
    IO.inspect(group)

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
        kelas = item |> elem(1) |> Enum.map(fn x -> x.class_name end) |> Enum.uniq()

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
          tak_lulus: fail,
          kelas: kelas
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
      if all != [] do
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
      else
        html = "No Data for Analysis"
      end

    {:reply, {:ok, %{html: html}}, socket}
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

  def handle_in("gen_std_achievement", payload, socket) do
    date_from = payload["date_from"]
    date_to = payload["date_to"]
    class_id = payload["class_id"]
    level_id = payload["level_id"]
    sort_id = payload["sort_id"]
    peringkat = payload["peringkat"]

    selection =
      cond do
        level_id != "ALL LEVEL" and class_id != "ALL CLASS" ->
          selection =
            Repo.all(
              from(
                sa in Affairs.Student_coco_achievement,
                left_join: c in Affairs.StudentClass,
                on: c.sudent_id == sa.student_id,
                left_join: t in Affairs.Class,
                on: t.id == c.class_id,
                left_join: s in Affairs.Student,
                on: s.id == sa.student_id,
                where:
                  sa.peringkat in ^peringkat and t.level_id == ^level_id and
                    c.class_id == ^class_id and
                    sa.date >= ^date_from and sa.date <= ^date_to,
                select: %{
                  desc: sa.competition_name,
                  student_name: s.name,
                  chinese_name: s.chinese_name,
                  date: sa.date,
                  peringkat: sa.peringkat,
                  class_name: t.name
                },
                order_by: [asc: sa.date]
              )
            )

        level_id != "ALL LEVEL" and class_id == "ALL CLASS" ->
          selection =
            Repo.all(
              from(
                sa in Affairs.Student_coco_achievement,
                left_join: c in Affairs.StudentClass,
                on: c.sudent_id == sa.student_id,
                left_join: t in Affairs.Class,
                on: t.id == c.class_id,
                left_join: s in Affairs.Student,
                on: s.id == sa.student_id,
                where:
                  sa.peringkat in ^peringkat and t.level_id == ^level_id and
                    sa.date >= ^date_from and sa.date <= ^date_to,
                select: %{
                  desc: sa.competition_name,
                  student_name: s.name,
                  chinese_name: s.chinese_name,
                  date: sa.date,
                  peringkat: sa.peringkat,
                  class_name: t.name
                },
                order_by: [asc: sa.date]
              )
            )

        level_id == "ALL LEVEL" ->
          selection =
            Repo.all(
              from(
                sa in Affairs.Student_coco_achievement,
                left_join: c in Affairs.StudentClass,
                on: c.sudent_id == sa.student_id,
                left_join: t in Affairs.Class,
                on: t.id == c.class_id,
                left_join: s in Affairs.Student,
                on: s.id == sa.student_id,
                where:
                  sa.peringkat in ^peringkat and
                    sa.date >= ^date_from and sa.date <= ^date_to,
                select: %{
                  desc: sa.competition_name,
                  student_name: s.name,
                  chinese_name: s.chinese_name,
                  date: sa.date,
                  peringkat: sa.peringkat,
                  class_name: t.name
                },
                order_by: [asc: sa.date]
              )
            )
      end

    sekolah =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Sekolah" end)

    zon =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Zon" end)

    negeri =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Negeri" end)

    kebangsaan =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Kebangsaan" end)

    antarabangsa =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Antarabangsa" end)

    html =
      if selection != [] do
        Phoenix.View.render_to_string(
          SchoolWeb.Student_coco_achievementView,
          "student_achievement_report.html",
          selection: selection,
          sekolah: sekolah,
          zon: zon,
          negeri: negeri,
          kebangsaan: kebangsaan,
          antarabangsa: antarabangsa,
          date_to: date_to,
          date_from: date_from,
          class_id: class_id,
          level_id: level_id,
          sort_id: sort_id,
          peringkat: peringkat
        )
      end

    {:reply, {:ok, %{html: html, selection: selection}}, socket}
  end

  def handle_in("all_report_cocurriculum", payload, socket) do
    cocurriculum = payload["cocurriculum"]
    co_level = payload["co_level"]
    class = payload["class"]
    co_semester = payload["co_semester"]
    sort_by = payload["sort_id"]
    sort_by = String.to_integer(sort_by)
    type = payload["type"]
    type = String.to_integer(type)

    sem = Repo.get(Semester, co_semester)

    students1 =
      Repo.all(
        from(
          s in School.Affairs.StudentCocurriculum,
          left_join: a in School.Affairs.Student,
          on: s.student_id == a.id,
          left_join: p in School.Affairs.CoCurriculum,
          on: s.cocurriculum_id == p.id,
          where: s.cocurriculum_id == ^cocurriculum and s.semester_id == ^co_semester,
          select: %{
            id: p.id,
            student_id: s.student_id,
            chinese_name: a.chinese_name,
            name: a.name,
            mark: s.mark,
            gender: a.sex,
            race: a.race
          }
        )
      )

    sc =
      if class == [] do
        sc =
          Repo.all(
            from(
              s in Student,
              left_join: sc in StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in Class,
              on: c.id == sc.class_id,
              where:
                sc.institute_id == ^sem.institution_id and
                  sc.semester_id == ^co_semester,
              select: %{
                student_id: s.id,
                class: c.name,
                class_id: c.id,
                level_id: sc.level_id
              }
            )
          )
      else
        sc =
          Repo.all(
            from(
              s in Student,
              left_join: sc in StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in Class,
              on: c.id == sc.class_id,
              where:
                c.id in ^class and sc.institute_id == ^sem.institution_id and
                  sc.semester_id == ^co_semester,
              select: %{
                student_id: s.id,
                class: c.name,
                class_id: c.id,
                level_id: sc.level_id
              }
            )
          )
      end

    students =
      for student <- students1 do
        if Enum.any?(sc, fn x -> x.student_id == student.student_id end) do
          b = sc |> Enum.filter(fn x -> x.student_id == student.student_id end) |> hd()

          student = Map.put(student, :class_name, b.class)
          student = Map.put(student, :class_id, b.class_id)
          student = Map.put(student, :level_id, b.level_id)
          student
        else
          student = Map.put(student, :class_name, "no class assigned")
          student = Map.put(student, :level_id, 0)
          student
        end
      end

    students = students |> Enum.filter(fn x -> x.class_name != "no class assigned" end)

    students =
      if co_level != "Choose a level" do
        students |> Enum.filter(fn x -> x.level_id == String.to_integer(co_level) end)
      else
        students
      end

    # IO.inspect(students)
    students =
      if sort_by == 3 do
        students |> Enum.sort_by(fn d -> d.name end)
      else
        students
      end

    students =
      if sort_by == 2 do
        students |> Enum.sort_by(fn d -> {d.class_name, d.name} end)
      else
        students
      end

    students =
      if sort_by == 1 do
        students |> Enum.sort_by(fn d -> {d.class_name, d.id} end)
      else
        students
      end

    summary = %{}

    summary =
      if type == 1 do
        male = Enum.filter(students, fn x -> x.gender == "Male" end)
        male_chinese = Enum.count(male, fn x -> x.race == "Chinese" end)
        male_malay = Enum.count(male, fn x -> x.race == "Malay" end)
        male_indian = Enum.count(male, fn x -> x.race == "Indian" end)
        #  male_other = Enum.count(male, fn x -> x.race == "other" end)

        female = Enum.filter(students, fn x -> x.gender == "Female" end)
        female_chinese = Enum.count(female, fn x -> x.race == "Chinese" end)
        female_malay = Enum.count(female, fn x -> x.race == "Malay" end)
        female_indian = Enum.count(female, fn x -> x.race == "Indian" end)
        # female_other = Enum.count(female, fn x -> x.race == "other" end)
        tot_chinese = male_chinese + female_chinese
        tot_indian = male_indian + female_indian
        tot_malay = male_malay + female_malay
        tot_std = tot_chinese + tot_malay + tot_indian

        # summary = Map.put(summary, :male, male)
        summary = Map.put(summary, :male_chinese, male_chinese)
        summary = Map.put(summary, :male_malay, male_malay)
        summary = Map.put(summary, :male_indian, male_indian)
        # Map.put(summary, :male_other, male_other)

        # summary = Map.put(summary, :female, female)
        summary = Map.put(summary, :female_chinese, female_chinese)
        summary = Map.put(summary, :female_malay, female_malay)
        summary = Map.put(summary, :female_indian, female_indian)

        summary = Map.put(summary, :tot_chinese, tot_chinese)
        summary = Map.put(summary, :tot_indian, tot_indian)
        summary = Map.put(summary, :tot_malay, tot_malay)
        summary = Map.put(summary, :tot_std, tot_std)

        # Map.put(summary, :female_other, female_other)
        summary
      else
        summary
      end

    html =
      if type == 1 do
        if students != [] do
          Phoenix.View.render_to_string(
            SchoolWeb.CoCurriculumView,
            "report_student_co.html",
            students: students,
            class: class,
            sort_by: sort_by,
            cocurriculum: cocurriculum,
            co_semester: co_semester,
            co_level: co_level,
            type: type,
            summary: summary
          )
        else
          "No Data inside..Please choose other."
        end
      else
        if students != [] do
          Phoenix.View.render_to_string(
            SchoolWeb.CoCurriculumView,
            "report2_student_co.html",
            students: students,
            class: class,
            sort_by: sort_by,
            cocurriculum: cocurriculum,
            co_semester: co_semester,
            co_level: co_level,
            type: type,
            summary: summary
          )
        else
          "No Data inside..Please choose other."
        end
      end

    {:reply, {:ok, %{html: html}}, socket}
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

        if user.role == "Teacher" do
          teacher = Repo.all(from(t in Teacher, where: t.email == ^user.email))

          if teacher != nil do
            teacher = teacher |> hd()
            Teacher.changeset(teacher, %{institution_id: institution.id}) |> Repo.update!()
          end
        end

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

  def handle_in("save_ui_color", %{"color" => color, "user_id" => user_id}, socket) do
    user = Repo.get(User, user_id)

    School.Settings.update_user(user, %{styles: "/" <> color})

    broadcast(socket, "load_ui_color", %{color: color})
    {:noreply, socket}
  end

  def handle_in("save_homework_details", params, socket) do
    {:ok, s_datetime, 0} = DateTime.from_iso8601(params["start_date"])
    {:ok, e_datetime, 0} = DateTime.from_iso8601(params["end_date"])

    s_date = s_datetime |> DateTime.to_date()
    e_date = e_datetime |> DateTime.to_date()

    ehomework_params = %{
      class_id: Integer.parse(params["class_id"]) |> elem(0),
      end_date: e_date,
      semester_id: Integer.parse(params["semester_id"]) |> elem(0),
      start_date: s_date,
      subject_id: Integer.parse(params["subject_id"]) |> elem(0),
      desc: params["description"]
    }

    case Affairs.create_ehomework(ehomework_params) do
      {:ok, ehomework} ->
        broadcast(socket, "show_calendar", %{
          "start_date" => s_datetime,
          "end_date" => e_datetime
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        nil
    end
  end

  def handle_in(
        "save_period",
        %{
          "period_id" => period_id,
          "user_id" => user_id,
          "start_date" => start_date,
          "end_date" => end_date,
          "event_id_str" => event_id_str,
          "institution_id" => institution_id,
          "semester_id" => semester_id
        },
        socket
      ) do
    {:ok, s_date, 0} = DateTime.from_iso8601(start_date)
    {:ok, e_date, 0} = DateTime.from_iso8601(end_date)

    if period_id == 0 do
      # create a new period 
      teacher = Affairs.get_teacher!(user_id)

      {:ok, timetable} =
        School.Affairs.initialize_calendar(institution_id, semester_id, teacher.id)

      subject_id = event_id_str |> String.split("_") |> List.first()
      class_id = event_id_str |> String.split("_") |> List.last()

      a =
        Affairs.create_period(%{
          start_datetime: s_date,
          end_datetime: e_date,
          timetable_id: timetable.id,
          teacher_id: teacher.id,
          subject_id: subject_id,
          class_id: class_id
        })

      case a do
        {:ok, period} ->
          if period.google_event_id != nil do
            flag_pending_sync(period.id)
          end

          broadcast(socket, "show_period_new", %{
            "start_date" => start_date,
            "end_date" => end_date
          })

        {:error, changeset} ->
          errors = changeset.errors |> Keyword.keys()

          {reason, message} = changeset.errors |> hd()
          {proper_message, message_list} = message
          final_reason = Atom.to_string(reason) <> " " <> proper_message

          broadcast(socket, "show_failed_period", %{
            "final_reason" => final_reason
          })
      end

      # user id is the teacher id
      # event_id is the subject_id 
    else
      case School.Affairs.get_teacher(user_id) do
        {:ok, teacher} ->
          {:ok, timetable} =
            School.Affairs.initialize_calendar(institution_id, semester_id, teacher.id)

          # need to find that period and update it
          period = Repo.get(School.Affairs.Period, period_id)

          period_params = %{
            start_datetime: s_date,
            end_datetime: e_date
          }

          if period.teacher_id == nil do
            period_params = Map.put(period_params, :teacher_id, teacher.id)
            period_params = Map.put(period_params, :timetable_id, timetable.id)
          end

          if period != nil do
            a = School.Affairs.update_period(period, period_params)

            case a do
              {:ok, period} ->
                if period.google_event_id != nil do
                  flag_pending_sync(period.id)
                end

                broadcast(socket, "show_period", %{
                  "period_id" => period_id,
                  "user_id" => user_id,
                  "start_date" => start_date,
                  "end_date" => end_date,
                  "event_id_str" => event_id_str
                })

              {:error, changeset} ->
                errors = changeset.errors |> Keyword.keys()

                {reason, message} = changeset.errors |> hd()
                {proper_message, message_list} = message
                final_reason = Atom.to_string(reason) <> " " <> proper_message

                broadcast(socket, "show_failed_period", %{
                  "period_id" => period_id,
                  "user_id" => user_id,
                  "start_date" => start_date,
                  "end_date" => end_date,
                  "event_id_str" => event_id_str,
                  "final_reason" => final_reason
                })
            end
          else
            broadcast(socket, "show_failed_period", %{
              "period_id" => period_id,
              "user_id" => user_id,
              "start_date" => start_date,
              "end_date" => end_date,
              "event_id_str" => event_id_str,
              "final_reason" => "block doesnt exist!"
            })
          end

        {:error, "no teacher assigned"} ->
          period = Repo.get(School.Affairs.Period, period_id)

          period_params = %{
            start_datetime: s_date,
            end_datetime: e_date
          }

          if period != nil do
            a = School.Affairs.update_period(period, period_params)

            case a do
              {:ok, period} ->
                if period.google_event_id != nil do
                  flag_pending_sync(period.id)
                end

                broadcast(socket, "show_period", %{
                  "period_id" => period_id,
                  "user_id" => user_id,
                  "start_date" => start_date,
                  "end_date" => end_date,
                  "event_id_str" => event_id_str
                })

              {:error, changeset} ->
                errors = changeset.errors |> Keyword.keys()

                {reason, message} = changeset.errors |> hd()
                {proper_message, message_list} = message
                final_reason = Atom.to_string(reason) <> " " <> proper_message

                broadcast(socket, "show_failed_period", %{
                  "period_id" => period_id,
                  "user_id" => user_id,
                  "start_date" => start_date,
                  "end_date" => end_date,
                  "event_id_str" => event_id_str,
                  "final_reason" => final_reason
                })
            end
          else
            broadcast(socket, "show_failed_period", %{
              "period_id" => period_id,
              "user_id" => user_id,
              "start_date" => start_date,
              "end_date" => end_date,
              "event_id_str" => event_id_str,
              "final_reason" => "block doesnt exist!"
            })
          end
      end
    end

    {:noreply, socket}
  end

  def flag_pending_sync(period_id) do
    School.Affairs.create_sync_list(%{period_id: period_id})
    true
  end

  def handle_in(
        "qs_term",
        %{"term" => term, "user_id" => user_id, "institution_id" => institution_id},
        socket
      ) do
    user = Repo.get(User, user_id)
    term = "%#{term}%"

    all_student =
      Repo.all(
        from(
          s in Student,
          where:
            s.institution_id == ^institution_id and
              (ilike(s.phone, ^term) or ilike(s.name, ^term) or ilike(s.chinese_name, ^term) or
                 ilike(s.ic, ^term) or ilike(s.b_cert, ^term) or ilike(s.gicno, ^term) or
                 ilike(s.ficno, ^term) or ilike(s.micno, ^term)),
          select: %{
            name: s.name,
            c_name: s.chinese_name,
            ic: s.ic,
            b_cert: s.b_cert,
            gicno: s.gicno,
            ficno: s.ficno,
            micno: s.micno,
            phone: s.phone,
            id: s.id
          },
          limit: 100
        )
      )

    # student =
    #   Repo.all(
    #     from(
    #       s in StudentClass,
    #       left_join: g in Student,
    #       on: s.sudent_id == g.id,
    #       where: g.institution_id == ^institution_id,
    #       select: %{
    #         name: g.name,
    #         c_name: g.chinese_name,
    #         ic: g.ic,
    #         b_cert: g.b_cert,
    #         gicno: g.gicno,
    #         ficno: g.ficno,
    #         micno: g.micno,
    #         phone: g.phone,
    #         id: g.id
    #       },
    #       limit: 100
    #     )
    #   )

    students = all_student

    {:reply, {:ok, %{students: students}}, socket}
  end

  def handle_in(
        "qt_term",
        %{"term" => term, "user_id" => user_id, "institution_id" => institution_id},
        socket
      ) do
    user = Repo.get(User, user_id)
    term = "%#{term}%"

    all_teacher =
      Repo.all(
        from(
          s in Teacher,
          where:
            s.institution_id == ^institution_id and
              (ilike(s.icno, ^term) or ilike(s.name, ^term) or ilike(s.cname, ^term) or
                 ilike(s.icno, ^term)),
          select: %{
            name: s.name,
            c_name: s.cname,
            ic: s.icno,
            id: s.id
          },
          limit: 100
        )
      )

    # student =
    #   Repo.all(
    #     from(
    #       s in StudentClass,
    #       left_join: g in Student,
    #       on: s.sudent_id == g.id,
    #       where: g.institution_id == ^institution_id,
    #       select: %{
    #         name: g.name,
    #         c_name: g.chinese_name,
    #         ic: g.ic,
    #         b_cert: g.b_cert,
    #         gicno: g.gicno,
    #         ficno: g.ficno,
    #         micno: g.micno,
    #         phone: g.phone,
    #         id: g.id
    #       },
    #       limit: 100
    #     )
    #   )

    students = all_teacher

    {:reply, {:ok, %{students: students}}, socket}
  end

  def handle_in(
        "qt_term_rfid",
        %{
          "term" => term,
          "user_id" => user_id,
          "institution_id" => institution_id,
          "semester_id" => semester_id,
          "mode" => mode,
          "date_time" => date_time
        },
        socket
      ) do
    user = Repo.get(User, user_id)

    teacher =
      Repo.get_by(School.Affairs.Teacher,
        secondid: term,
        institution_id: institution_id
      )

    if teacher != nil do
      teacher_id = teacher.id

      date_time = date_time

      time_in = date_time

      date = time_in |> String.split(" ") |> hd

      month = date |> String.split("-") |> Enum.fetch!(1)

      attns =
        Repo.get_by(School.Affairs.TeacherAttendance,
          teacher_id: teacher_id,
          institution_id: institution_id,
          date: date
        )

      msg =
        if attns == nil do
          msg =
            if mode == "time_out" do
              params = %{
                institution_id: institution_id,
                semester_id: semester_id,
                teacher_id: teacher_id,
                time_out: time_in,
                date: date,
                month: month
              }

              Affairs.create_teacher_attendance(params)
              msg = "Created Succesfully"
            else
              params = %{
                institution_id: institution_id,
                semester_id: semester_id,
                teacher_id: teacher_id,
                time_in: time_in,
                date: date,
                month: month
              }

              Affairs.create_teacher_attendance(params)
              msg = "Created Succesfully"
            end

          msg
        else
          attn =
            Repo.get_by(School.Affairs.TeacherAttendance,
              teacher_id: teacher_id,
              institution_id: institution_id,
              date: date
            )

          msg =
            if mode == "time_in" do
              msg =
                if attn.time_in == nil do
                  params = %{
                    time_in: time_in
                  }

                  Affairs.update_teacher_attendance(attn, params)

                  msg = "Created Succesfully"
                else
                  msg = "Time In alrdy fill up"
                end

              msg
            else
              msg =
                if attn.time_out == nil do
                  c = attn.time_in |> String.split(" ") |> Enum.fetch(1)
                  a = time_in |> String.split(" ") |> Enum.fetch(1)

                  day_name = Timex.now().day |> Timex.day_name()

                  shift =
                    Repo.all(
                      from(s in School.Affairs.Shift,
                        left_join: r in School.Affairs.ShiftMaster,
                        on: s.shift_master_id == r.id,
                        where: s.teacher_id == ^teacher_id,
                        select: %{start_time: r.start_time, end_time: r.end_time, day: r.day}
                      )
                    )

                  shift =
                    if shift != [] do
                      shiftss =
                        shift |> Enum.filter(fn x -> x.day |> String.split(",") == day_name end)

                      shifts =
                        if shiftss != [] do
                          shift |> hd
                          %{start_time: shift.start_time, end_time: shift.end_time}
                        else
                          %{start_time: "07:30:00", end_time: "13:20:00"}
                        end

                      shifts
                    else
                      %{start_time: "07:30:00", end_time: "13:20:00"}
                    end

                  tf =
                    time_in
                    |> String.split(" ")
                    |> Enum.fetch!(1)
                    |> String.split(":")

                  ti1 = tf |> Enum.fetch!(0)
                  ti2 = tf |> Enum.fetch!(1)
                  ti3 = tf |> Enum.fetch!(2)

                  ti1 =
                    if ti1 |> String.to_integer() <= 9 do
                      "0" <> ti1
                    else
                      ti1
                    end

                  ti2 =
                    if ti2 |> String.to_integer() <= 9 do
                      "0" <> ti2
                    else
                      ti2
                    end

                  ti3 =
                    if ti3 |> String.to_integer() <= 9 do
                      "0" <> ti3
                    else
                      ti3
                    end

                  new_time_in = ti1 <> ":" <> ti2 <> ":" <> ti3
                  a = new_time_in

                  remark =
                    if a < shift.end_time do
                      remark = "BALIK AWAL"
                    else
                      remark =
                        if c > shift.start_time do
                          remark = "LEWAT"
                        else
                          remark =
                            if a > shift.end_time and c < shift.end_time do
                              remark = "HADIR"
                            end

                          remark
                        end

                      remark
                    end

                  params = %{
                    time_out: time_in,
                    remark: remark
                  }

                  Affairs.update_teacher_attendance(attn, params)

                  msg = "Created Succesfully"
                else
                  msg = "Time In alrdy fill up"
                end

              msg
            end

          msg
        end

      broadcast(socket, "rep", %{msg: msg})
      {:noreply, socket}

      # {:reply, {:ok, %{msg: msg}}, socket}
    else
      broadcast(socket, "rep", %{msg: "Wrong RFID"})
      {:noreply, socket}
    end
  end

  def handle_in(
        "load_class_students",
        %{
          "semester_id" => semester_id,
          "class_id" => class_id,
          "user_id" => user_id,
          "institution_id" => institution_id
        },
        socket
      ) do
    students = Affairs.get_student_list(class_id, semester_id)

    {:reply, {:ok, %{students: students}}, socket}
  end

  def handle_in(
        "create_teacher_attendance",
        %{
          "semester_id" => semester_id,
          "user_id" => user_id,
          "institution_id" => institution_id,
          "teacher_id" => teacher_id,
          "mode" => mode
        },
        socket
      ) do
    date_time = NaiveDateTime.utc_now()

    time_in = NaiveDateTime.to_string(date_time)

    date = time_in |> String.split_at(10) |> elem(0)

    attns =
      Repo.get_by(School.Affairs.TeacherAttendance,
        teacher_id: teacher_id,
        institution_id: institution_id,
        date: date
      )

    msg =
      if attns == nil do
        msg =
          if mode == "time_out" do
            msg = "Plese Switch to Time In Mode"
          else
            params = %{
              institution_id: institution_id,
              semester_id: semester_id,
              teacher_id: teacher_id,
              time_in: time_in,
              date: date
            }

            Affairs.create_teacher_attendance(params)
            msg = "Created Succesfully"
          end

        msg
      else
        attn =
          Repo.get_by(School.Affairs.TeacherAttendance,
            teacher_id: teacher_id,
            institution_id: institution_id,
            date: date
          )

        msg =
          if mode == "time_in" do
            msg =
              if attn.time_in == nil do
                params = %{
                  time_in: time_in
                }

                Affairs.update_teacher_attendance(attn, params)

                msg = "Created Succesfully"
              else
                msg = "Time In alrdy fill up"
              end

            msg
          else
            msg =
              if attn.time_out == nil do
                params = %{
                  time_out: time_in
                }

                Affairs.update_teacher_attendance(attn, params)

                msg = "Created Succesfully"
              else
                msg = "Time In alrdy fill up"
              end

            msg
          end

        msg
      end

    broadcast(socket, "show_teacher_attendance_record", %{})
    {:noreply, socket}
  end

  def handle_in(
        "load_coco_students",
        %{
          "semester_id" => semester_id,
          "coco_id" => coco_id,
          "user_id" => user_id,
          "institution_id" => institution_id
        },
        socket
      ) do
    students = Affairs.list_student_cocurriculum(coco_id, semester_id)

    {:reply, {:ok, %{students: students}}, socket}
  end

  def handle_in(
        "add_class_students",
        %{
          "student_id" => student_id,
          "semester_id" => semester_id,
          "class_id" => class_id,
          "user_id" => user_id,
          "institution_id" => institution_id
        },
        socket
      ) do
    class = Affairs.get_class!(class_id)
    student = Affairs.get_student!(student_id)

    case Affairs.create_student_class(%{
           class_id: class_id,
           institute_id: institution_id,
           semester_id: semester_id,
           sudent_id: student_id,
           level_id: class.level_id
         }) do
      {:ok, sc} ->
        students = Affairs.get_student_list(class_id, semester_id)

        all_student =
          Repo.all(
            from(
              s in Student,
              where: s.institution_id == ^institution_id,
              select: %{
                name: s.name,
                c_name: s.chinese_name,
                ic: s.ic,
                b_cert: s.b_cert,
                gicno: s.gicno,
                ficno: s.ficno,
                micno: s.micno,
                phone: s.phone,
                id: s.id
              },
              limit: 100
            )
          )

        student =
          Repo.all(
            from(
              s in StudentClass,
              left_join: g in Student,
              on: s.sudent_id == g.id,
              where:
                g.institution_id == ^institution_id and s.class_id == ^class_id and
                  s.semester_id == ^semester_id,
              select: %{
                name: g.name,
                c_name: g.chinese_name,
                ic: g.ic,
                b_cert: g.b_cert,
                gicno: g.gicno,
                ficno: g.ficno,
                micno: g.micno,
                phone: g.phone,
                id: g.id
              },
              limit: 100
            )
          )

        all_student = all_student -- student

        {:reply, {:ok, %{students: students, all_student: all_student}}, socket}

      {:error, changeset} ->
        Process.sleep(500)

        ex_class =
          Repo.get(
            Class,
            Repo.get_by(StudentClass, sudent_id: student_id, semester_id: semester_id).class_id
          )

        {:reply,
         {:error,
          %{
            name: student.name,
            student_id: student.id,
            class: class.name,
            ex_class: ex_class.name
          }}, socket}
    end
  end

  def handle_in("remove_from_class", payload, socket) do
    ex_class =
      Repo.get_by(
        School.Affairs.StudentClass,
        sudent_id: payload["student_id"],
        semester_id: payload["semester_id"],
        class_id: payload["class_id"]
      )

    student = Affairs.get_student!(payload["student_id"])

    Affairs.delete_student_class(ex_class)

    students = Affairs.get_student_list(payload["class_id"], payload["semester_id"])

    {:reply, {:error, %{students: students, name: student.name, student_id: student.id}}, socket}
  end

  def handle_in("tranfer_from_class", payload, socket) do
    ex_class =
      Repo.get_by(
        School.Affairs.StudentClass,
        sudent_id: payload["student_id"],
        semester_id: payload["semester_id"],
        class_id: payload["class_id"]
      )

    new_class = %{
      sudent_id: payload["student_id"],
      semester_id: payload["semester_id"],
      class_id: payload["classes_id"],
      institute_id: payload["institution_id"]
    }

    student = Affairs.get_student!(payload["student_id"])

    Affairs.delete_student_class(ex_class)

    Affairs.create_student_class(new_class)

    students = Affairs.get_student_list(payload["class_id"], payload["semester_id"])

    {:reply, {:error, %{students: students, name: student.name, student_id: student.id}}, socket}
  end

  def handle_in("change_semester", payload, socket) do
    semester =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where:
            s.id == ^payload["semester_id"] and s.institution_id == ^payload["institution_id"]
        )
      )
      |> hd

    user = Repo.get_by(User, id: payload["user_id"])

    # conn = %{
    #   private: %{
    #     plug_session: %{
    #       "institution_id" => payload["institution_id"],
    #       "user_id" => payload["user_id"],
    #       "semester_id" => payload["semester_id"],
    #       "style" => user.styles
    #     }
    #   }
    # }

    # conn
    #      |> put_session(:user_id, user.id)
    #      |> put_session(:semester_id, payload["semester_id"]
    #      |> put_session(:institution_id, payload["institution_id"])
    #      |> put_session(:style, user.styles)

    action = "Semester Updated"

    broadcast(socket, "semester_changed", %{
      action: action,
      semester: payload["semester_id"]
    })

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
