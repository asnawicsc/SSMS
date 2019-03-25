defmodule SchoolWeb.ExamController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Exam
  alias School.Affairs.ExamMaster
  require IEx

  def index(conn, _params) do
    exam_semester =
      Repo.all(
        from(
          e in Exam,
          left_join: em in ExamMaster,
          on: em.id == e.exam_master_id,
          left_join: s in Subject,
          on: e.subject_id == s.id,
          left_join: sm in Semester,
          on: em.semester_id == sm.id,
          left_join: l in Level,
          on: em.level_id == l.id,
          group_by: [em.id, em.name, l.id, sm.start_date, sm.id],
          where: em.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            exam_master_id: em.id,
            exam_name: em.name,
            semester: sm.start_date,
            semester_id: sm.id,
            level: l.name,
            level_id: l.id
          }
        )
      )

    render(conn, "exam_semester.html", exam_semester: exam_semester)
  end

  def report_nav(conn, params) do
    render(conn, "report_nav.html")
  end

  def list_report(conn, params) do
    render(conn, "list_report.html")
  end

  def list_report_history(conn, params) do
    render(conn, "list_report_history.html")
  end

  def new(conn, _params) do
    changeset = Affairs.change_exam(%Exam{})
    render(conn, "new.html", changeset: changeset)
  end

  def new_exam(conn, params) do
    inst_id = Affairs.get_inst_id(conn)

    subjects =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          where: s.institution_id == ^inst_id,
          select: %{id: s.id, code: s.code, name: s.description}
        )
      )

    semester = Affairs.list_semesters(inst_id)

    levels =
      Affairs.list_levels()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "new_exam.html", subjects: subjects, semester: semester, level: levels)
  end

  def create_exam(conn, params) do
    exam_name = params["exam_name"]
    level_id = params["level"]
    semester_id = params["semester"]
    institution_id = conn.private.plug_session["institution_id"]

    subjects = params["subject"] |> String.split(",")

    exam_master_params = %{
      name: exam_name,
      level_id: level_id,
      semester_id: semester_id,
      institution_id: institution_id
    }

    case Affairs.create_exam_master(exam_master_params) do
      {:ok, exam_master} ->
        id = exam_master.id

        for subject <- subjects do
          exam_params = %{exam_master_id: id, subject_id: subject}
          changeset = Affairs.change_exam(%Exam{})
          Affairs.create_exam(exam_params)
        end

        conn
        |> put_flash(:info, "Exam created successfully.")
        |> redirect(to: exam_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def generate_mark_analyse(conn, %{"id" => id}) do
    exam =
      Repo.all(
        from(
          e in School.Affairs.ExamMaster,
          left_join: c in School.Affairs.Class,
          on: c.level_id == e.level_id,
          where: c.id == ^id,
          select: %{id: e.id, exam_name: e.name}
        )
      )

    render(conn, "generate_mark_analyse.html", exam: exam, id: id)
  end

  def mark_analyse(conn, params) do
    class_id = params["class_id"]
    exam_name = params["exam_name"]

    class = Repo.get_by(School.Affairs.Class, %{id: class_id})

    exam = Repo.get_by(School.Affairs.ExamMaster, %{name: exam_name, level_id: class.level_id})

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

    if all == [] do
      conn
      |> put_flash(:info, "Please Insert Exam Record First")
      |> redirect(to: class_path(conn, :index))
    end

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
                g in School.Affairs.Grade,
                where: g.institution_id == ^conn.private.plug_session["institution_id"]
              )
            )

          # grades =
          #   Repo.all(
          #     from(g in School.Affairs.ExamGrade,
          #       where:
          #         g.institution_id == ^conn.private.plug_session["institution_id"] and
          #           g.exam_master_id == ^exam.id
          #     )
          #   )

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

    render(
      conn,
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
      class: class
    )
  end

  def create(conn, %{"exam" => exam_params}) do
    case Affairs.create_exam(exam_params) do
      {:ok, exam} ->
        conn
        |> put_flash(:info, "Exam created successfully.")
        |> redirect(to: exam_path(conn, :show, exam))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def mark_sheet(conn, params) do
    user = Repo.get_by(School.Settings.User, %{id: conn.private.plug_session["user_id"]})

    {class, a} =
      if user.role == "Admin" or user.role == "Support" do
        class =
          Repo.all(
            from(
              s in School.Affairs.Class,
              where: s.institution_id == ^conn.private.plug_session["institution_id"],
              select: %{id: s.id, name: s.name}
            )
          )

        a =
          Repo.all(
            from(
              p in School.Affairs.Exam,
              left_join: m in School.Affairs.ExamMaster,
              on: m.id == p.exam_master_id,
              left_join: q in School.Affairs.Level,
              on: q.id == m.level_id,
              left_join: g in School.Affairs.Subject,
              on: g.id == p.subject_id,
              left_join: s in School.Affairs.Class,
              on: s.level_id == m.level_id,
              where:
                m.semester_id == ^conn.private.plug_session["semester_id"] and
                  s.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  q.institution_id == ^conn.private.plug_session["institution_id"] and
                  m.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.is_delete == 0,
              select: %{
                id: p.id,
                c_id: s.id,
                s_id: g.id,
                class: s.name,
                exam: m.name,
                subject: g.description
              }
            )
          )

        IO.inspect(a)

        {class, a}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        class =
          Repo.all(
            from(
              p in School.Affairs.Period,
              left_join: f in School.Affairs.Timetable,
              on: p.timetable_id == f.id,
              left_join: s in School.Affairs.Class,
              on: s.id == p.class_id,
              where:
                f.institution_id == ^conn.private.plug_session["institution_id"] and
                  f.semester_id == ^conn.private.plug_session["semester_id"] and
                  s.institution_id == ^conn.private.plug_session["institution_id"] and
                  p.teacher_id == ^teacher.id,
              select: %{id: s.id, name: s.name}
            )
          )

        class =
          if class != [] do
            class |> Enum.uniq()
          else
            class
          end

        period_subjects =
          Repo.all(
            from(
              p in School.Affairs.Period,
              left_join: f in School.Affairs.Timetable,
              on: p.timetable_id == f.id,
              left_join: s in School.Affairs.Subject,
              on: s.id == p.subject_id,
              left_join: c in School.Affairs.Class,
              on: c.id == p.class_id,
              left_join: t in School.Affairs.Teacher,
              on: t.id == p.teacher_id,
              where:
                f.teacher_id == ^teacher.id and p.teacher_id == ^teacher.id and
                  f.institution_id == ^conn.private.plug_session["institution_id"] and
                  f.semester_id == ^conn.private.plug_session["semester_id"] and
                  s.institution_id == ^conn.private.plug_session["institution_id"],
              select: %{
                subject: s.timetable_description,
                class: c.name,
                teacher: t.id
              }
            )
          )
          |> Enum.uniq()

        # new =
        #   Repo.all(
        #     from(
        #       p in School.Affairs.Exam,
        #       left_join: m in School.Affairs.ExamMaster,
        #       on: m.id == p.exam_master_id,
        #       left_join: q in School.Affairs.Level,
        #       on: q.id == m.level_id,
        #       left_join: g in School.Affairs.Subject,
        #       on: g.id == p.subject_id,
        #       left_join: s in School.Affairs.Class,
        #       on: s.level_id == m.level_id,
        #       where:
        #         m.semester_id == ^conn.private.plug_session["semester_id"] and
        #           s.institution_id == ^conn.private.plug_session["institution_id"] and
        #           g.institution_id == ^conn.private.plug_session["institution_id"] and
        #           q.institution_id == ^conn.private.plug_session["institution_id"] and
        #           m.institution_id == ^conn.private.plug_session["institution_id"] and
        #           s.is_delete == 0,
        #       select: %{
        #         id: p.id,
        #         c_id: s.id,
        #         s_id: g.id,
        #         class: s.name,
        #         exam: m.name,
        #         subject: g.description,
        #         subject_timetable: g.timetable_description
        #       }
        #     )
        #   )

        # a = new

        a =
          for period_subject <- period_subjects do
            b =
              Repo.all(
                from(
                  p in School.Affairs.Exam,
                  left_join: m in School.Affairs.ExamMaster,
                  on: m.id == p.exam_master_id,
                  left_join: q in School.Affairs.Level,
                  on: q.id == m.level_id,
                  left_join: g in School.Affairs.Subject,
                  on: g.id == p.subject_id,
                  left_join: s in School.Affairs.Class,
                  on: s.level_id == m.level_id,
                  left_join: k in School.Affairs.Teacher,
                  where:
                    m.semester_id == ^conn.private.plug_session["semester_id"] and
                      s.institution_id == ^conn.private.plug_session["institution_id"] and
                      g.institution_id == ^conn.private.plug_session["institution_id"] and
                      q.institution_id == ^conn.private.plug_session["institution_id"] and
                      m.institution_id == ^conn.private.plug_session["institution_id"] and
                      s.is_delete == 0 and g.timetable_description == ^period_subject.subject and
                      s.name == ^period_subject.class and k.id == ^period_subject.teacher,
                  select: %{
                    id: p.id,
                    c_id: s.id,
                    s_id: g.id,
                    class: s.name,
                    exam: m.name,
                    subject: g.description,
                    teacher_name: k.name,
                    cname: k.cname
                  }
                )
              )

            b
          end
          |> List.flatten()
          |> Enum.uniq()

        {class, a}
      end

    if class == [] do
      conn
      |> put_flash(:info, "You Dont Teach Any Subject.")
      |> redirect(to: page_path(conn, :dashboard))
    else
      if user.role == "Admin" or user.role == "Support" do
        render(conn, "mark_sheet.html", class: class, a: a)
      else
        render(conn, "mark_sheet_teacher.html", class: class, a: a)
      end
    end
  end

  def generate_exam(conn, params) do
    all =
      Repo.all(
        from(
          p in School.Affairs.SubjectTeachClass,
          left_join: sb in School.Affairs.Subject,
          on: sb.id == p.subject_id,
          left_join: s in School.Affairs.Class,
          on: p.class_id == s.id,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          select: %{id: sb.id, t_name: t.name, s_code: sb.code, subject: sb.description}
        )
      )
      |> Enum.uniq()
      |> Enum.filter(fn x -> x.t_name != "Rehat" end)

    exam =
      Repo.all(
        from(
          e in School.Affairs.ExamMaster,
          select: %{id: e.id, exam_name: e.name}
        )
      )

    class =
      Repo.all(
        from(
          e in School.Affairs.Class,
          select: %{id: e.id, name: e.name}
        )
      )

    all =
      if all == [] do
        conn
        |> put_flash(:info, "Please Create Exam Subject.")
        |> redirect(to: class_path(conn, :index))
      else
        Repo.all(
          from(
            p in School.Affairs.SubjectTeachClass,
            left_join: sb in School.Affairs.Subject,
            on: sb.id == p.subject_id,
            left_join: s in School.Affairs.Class,
            on: p.class_id == s.id,
            left_join: t in School.Affairs.Teacher,
            on: t.id == p.teacher_id,
            select: %{id: sb.id, t_name: t.name, s_code: sb.code, subject: sb.description}
          )
        )
        |> Enum.uniq()
        |> Enum.filter(fn x -> x.t_name != "Rehat" end)
      end

    render(conn, "generate_exam.html", class: class, all: all, exam: exam)
  end

  def marking(conn, params) do
    subject_id = params["s_id"]
    class_id = params["c_id"]
    exam_id = params["id"]

    exam = Repo.get_by(School.Affairs.Exam, %{id: exam_id, subject_id: subject_id})
    exam_master = Repo.get_by(School.Affairs.ExamMaster, id: exam.exam_master_id)

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

    if all == [] do
      class =
        Repo.get_by(School.Affairs.Class, %{
          id: class_id,
          institution_id: conn.private.plug_session["institution_id"]
        })

      subject =
        Repo.get_by(School.Affairs.Subject, %{
          id: subject_id,
          institution_id: conn.private.plug_session["institution_id"]
        })

      verify =
        Repo.all(
          from(
            s in School.Affairs.Period,
            where: s.class_id == ^class.id and s.subject_id == ^subject.id,
            select: %{teacher_id: s.teacher_id}
          )
        )

      student =
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: p in Student,
            on: p.id == s.sudent_id,
            where:
              s.class_id == ^class.id and
                p.institution_id == ^conn.private.plug_session["institution_id"] and
                s.semester_id == ^exam_master.semester_id,
            select: %{id: p.id, student_name: p.name}
          )
        )

      if student == [] do
        conn
        |> put_flash(:info, "No Student in the Class,Please Enroll Student to Class first.")
        |> redirect(to: exam_path(conn, :mark_sheet))
      else
        render(
          conn,
          "mark.html",
          all: all,
          student: student,
          class: class,
          subject: subject,
          exam_id: exam_id
        )
      end
    else
      class =
        Repo.get_by(School.Affairs.Class, %{
          id: class_id,
          institution_id: conn.private.plug_session["institution_id"]
        })

      exam_id = params["id"]

      subject =
        Repo.get_by(School.Affairs.Subject, %{
          id: subject_id,
          institution_id: conn.private.plug_session["institution_id"]
        })

      # all_student=Repo.all(from s in School.Affairs.StudentClass,   
      #   where: e.subject_id==^subject.id and s.class_id==^class.id and e.exam_id==^exam_id and e.student_id != s.sudent_id,
      #   select: %{
      #     name: s.sudent_id,
      #     mark: e.mark
      #     })
      t =
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: p in Student,
            on: p.id == s.sudent_id,
            where:
              s.class_id == ^class.id and
                p.institution_id == ^conn.private.plug_session["institution_id"] and
                s.semester_id == ^exam_master.semester_id,
            select: %{id: p.id, student_name: p.name}
          )
        )

      fi =
        for item <- t do
          a = Enum.filter(all, fn x -> x.student_id == item.id end)

          if a == [] do
            %{
              class_id: class_id,
              exam_id: exam_id,
              student_id: item.id,
              subject_id: subject_id,
              student_name: item.student_name,
              mark: 0
            }
          else
          end
        end
        |> Enum.filter(fn x -> x != nil end)

      # csrf = Phoenix.Controller.get_csrf_token()

      # {Phoenix.View.render_to_string(
      #    SchoolWeb.ExamView,
      #    "edit_mark.html",
      #    all: all,
      #    fi: fi,
      #    class: class,
      #    exam_id: exam_id,
      #    subject: subject,

      #  )}

      render(
        conn,
        "edit_mark.html",
        all: all,
        fi: fi,
        class: class,
        exam_id: exam_id,
        subject: subject,
        exam_master: exam_master
      )
    end
  end

  def mark(conn, params) do
    class_id = params["class_id"]
    subject_id = params["subject_id"]
    exam_id = params["exam_id"]

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

      if verify == [] do
      else
      end

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

      render(
        conn,
        "mark.html",
        student: student,
        class: class,
        subject: subject,
        exam_id: exam_id
      )
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

      render(
        conn |> put_flash(:info, "Exam  mark already filled, please edit existing mark."),
        "edit_mark.html",
        all: all,
        fi: fi,
        class: class,
        exam_id: exam_id,
        subject: subject
      )
    end
  end

  def exam_result_class(conn, params) do
    user = Repo.get_by(School.Settings.User, %{id: conn.private.plug_session["user_id"]})
    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    # ad =
    #  if teacher != nil do
    #    Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})
    #  end

    level =
      Repo.all(from(l in School.Affairs.Level))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    class = Affairs.list_classes(Affairs.get_inst_id(conn))

    render(
      conn,
      "exam_result_class.html",
      class: class,
      level: level
    )
  end

  def exam_report(conn, params) do
    class_id = params["class_id"] |> String.to_integer()
    exam_id = params["exam_id"] |> String.to_integer()
    class = Repo.get_by(School.Affairs.Class, id: class_id)
    inst_id = conn.private.plug_session["institution_id"]

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

    if exam_mark != [] do
      level_id = hd(exam_mark).level_id

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

      render(
        conn,
        "rank.html",
        z: k,
        class: class,
        exam_name: exam_name,
        mark: mark,
        mark1: mark1,
        total_student: total_student,
        class_id: params["class_id"],
        exam_id: params["exam_id"]
      )
    else
      conn
      |> put_flash(:info, "Exam created successfully.")
      |> redirect(to: exam_path(conn, :exam_result_class))
    end
  end

  def exam_result_analysis_class(conn, params) do
    user = Repo.get_by(School.Settings.User, %{id: conn.private.plug_session["user_id"]})

    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    # ad =
    #  if teacher != nil do
    #   Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})
    # end

    class =
      Repo.all(
        from(
          s in School.Affairs.Class,
          select: %{institution_id: s.institution_id, id: s.id, name: s.name}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(
      conn,
      "exam_result_analysis_class.html",
      class: class
    )
  end

  def exam_result_standard(conn, params) do
    level =
      Repo.all(from(l in School.Affairs.Level))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(
      conn,
      "exam_result_standard.html",
      level: level
    )
  end

  def exam_result_analysis_standard(conn, params) do
    level =
      Repo.all(from(l in School.Affairs.Level))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(
      conn,
      "exam_result_analysis_standard.html",
      level: level
    )
  end

  def create_mark(conn, params) do
    class_id = params["class_id"]
    mark = params["mark"]
    subject_id = params["subject_id"]
    exam_id = params["exam_id"]

    exam =
      Repo.get_by(School.Affairs.Exam, %{
        id: exam_id,
        subject_id: subject_id
      })

    a =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam.exam_master_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    exam_name = a.name

    for item <- mark do
      student_id = item |> elem(0)
      mark = item |> elem(1)

      exam_mark_params = %{
        class_id: class_id,
        exam_id: exam_id,
        mark: mark,
        subject_id: subject_id,
        student_id: student_id
      }

      Affairs.create_exam_mark(exam_mark_params)
    end

    conn
    |> put_flash(:info, "Exam mark created successfully.")
    |> redirect(to: exam_path(conn, :mark_sheet))
  end

  def update_mark(conn, params) do
    class_id = params["class_id"]
    mark = params["mark"]
    subject_id = params["subject_id"]
    exam_id = params["exam_id"]

    exam =
      Repo.get_by(School.Affairs.Exam, %{
        id: exam_id,
        subject_id: subject_id
      })

    a =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam.exam_master_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    exam_name = a.name

    for item <- mark do
      student_id = item |> elem(0)
      mark = item |> elem(1)

      exam_mark =
        Repo.get_by(School.Affairs.ExamMark, %{
          exam_id: exam_id,
          subject_id: subject_id,
          student_id: student_id
        })

      exam_mark_params = %{
        class_id: class_id,
        exam_id: exam_id,
        mark: mark,
        subject_id: subject_id,
        student_id: student_id
      }

      if exam_mark == nil do
        Affairs.create_exam_mark(exam_mark_params)
      else
        exam_mark_params = %{
          class_id: class_id,
          exam_id: exam_id,
          mark: mark,
          subject_id: subject_id,
          student_id: student_id
        }

        Affairs.update_exam_mark(exam_mark, exam_mark_params)
      end
    end

    conn
    |> put_flash(:info, "Exam mark updated successfully.")
    |> redirect(to: exam_path(conn, :mark_sheet))
  end

  def rank_exam(conn, %{"id" => id}) do
    exam =
      Repo.all(
        from(
          e in School.Affairs.ExamMaster,
          left_join: c in School.Affairs.Class,
          on: c.level_id == e.level_id,
          where: c.id == ^id,
          select: %{id: e.id, exam_name: e.name}
        )
      )

    render(conn, "rank_exam.html", exam: exam, id: id)
  end

  def rank(conn, params) do
    class_id = params["class_id"] |> String.to_integer()
    exam_id = params["exam_id"] |> String.to_integer()

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
          where: e.class_id == ^class_id and e.exam_id == ^exam_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark
          }
        )
      )

    if exam_mark != [] do
      exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd

      all_mark = exam_mark |> Enum.group_by(fn x -> x.subject_code end)

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
                  where: g.institution_id == ^conn.private.plug_session["institution_id"]
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
                  student_mark: student_mark
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
          total = new |> elem(1) |> Enum.map(fn x -> x.student_mark end) |> Enum.sum()

          per = new |> elem(1) |> Enum.map(fn x -> x.student_mark end) |> Enum.count()
          total_per = per * 100

          student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd

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
            student_id: student_id,
            total_mark: total,
            per: per,
            total_per: total_per,
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
            student_id: item.student_id,
            total_mark: item.total_mark,
            per: item.per,
            total_per: item.total_per,
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

      render(conn, "rank.html", z: k, exam_name: exam_name, mark: mark, mark1: mark1)
    else
      conn
      |> put_flash(:info, "Please Insert Exam Record First")
      |> redirect(to: class_path(conn, :index))
    end
  end

  def report_card(conn, %{
        "id" => id,
        "exam_name" => exam_name,
        "exam_id" => exam_id,
        "rank" => rank
      }) do
    student_rank = rank |> String.split("-") |> List.to_tuple() |> elem(0)
    total_student_in_class = rank |> String.split("-") |> List.to_tuple() |> elem(1)

    {standard_rank, total_student} =
      if rank |> String.split("-") |> Enum.count() == 4 do
        standard_rank = rank |> String.split("-") |> List.to_tuple() |> elem(2)
        total_student = rank |> String.split("-") |> List.to_tuple() |> elem(3)

        {standard_rank, total_student}
      else
        standard_rank = nil
        total_student = nil

        {standard_rank, total_student}
      end

    student =
      Repo.get_by(
        School.Affairs.Student,
        id: id,
        institution_id: conn.private.plug_session["institution_id"]
      )

    student_comment = Repo.get_by(School.Affairs.StudentComment, student_id: student.id)

    institution = Repo.get(Institution, conn.private.plug_session["institution_id"])

    all =
      Repo.all(
        from(
          em in School.Affairs.ExamMark,
          left_join: z in School.Affairs.Exam,
          on: em.exam_id == z.id,
          left_join: e in School.Affairs.ExamMaster,
          on: z.exam_master_id == e.id,
          left_join: j in School.Affairs.Semester,
          on: e.semester_id == j.id,
          left_join: s in School.Affairs.Student,
          on: em.student_id == s.id,
          left_join: sc in School.Affairs.StudentClass,
          on: sc.sudent_id == s.id,
          left_join: c in School.Affairs.Class,
          on: em.class_id == c.id,
          left_join: sb in School.Affairs.Subject,
          on: em.subject_id == sb.id,
          where:
            em.student_id == ^student.id and e.name == ^exam_name and
              c.institution_id == ^institution.id and e.institution_id == ^institution.id and
              j.institution_id == ^institution.id and s.institution_id == ^institution.id and
              sb.institution_id == ^institution.id and sc.institute_id == ^institution.id,
          select: %{
            student_name: s.name,
            chinese_name: s.chinese_name,
            class_name: c.name,
            semester: j.id,
            subject_code: sb.code,
            subject_name: sb.description,
            subject_cname: sb.cdesc,
            mark: em.mark,
            standard_id: e.level_id
          }
        )
      )
      |> Enum.uniq()

    exam =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    all_data =
      for data <- all do
        grades =
          Repo.all(
            from(
              g in School.Affairs.ExamGrade,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.exam_master_id == ^exam.id
            )
          )

        for grade <- grades do
          if data.mark >= grade.min and data.mark <= grade.max do
            %{
              class_name: data.class_name,
              semester: data.semester,
              student_name: data.student_name,
              chinese_name: data.chinese_name,
              grade: grade.name,
              gpa: grade.gpa,
              subject_code: data.subject_code,
              subject_name: data.subject_name,
              subject_cname: data.subject_cname,
              student_mark: data.mark
            }
          end
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    student_name = all_data |> Enum.map(fn x -> x.student_name end) |> Enum.uniq() |> hd
    student_cname = all_data |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd

    class_name = all_data |> Enum.map(fn x -> x.class_name end) |> Enum.uniq() |> hd

    a = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
    b = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
    c = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
    d = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
    e = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
    f = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
    g = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

    per = all_data |> Enum.map(fn x -> x.student_mark end) |> Enum.count()
    total_mark = all_data |> Enum.map(fn x -> x.student_mark end) |> Enum.sum()
    total_gpa = all_data |> Enum.map(fn x -> Decimal.to_float(x.gpa) end) |> Enum.sum()
    cgpa = (total_gpa / per) |> Float.round(2)

    total_per = per * 100

    total_average = (total_mark / total_per * 100) |> Float.round(2)
    semester = Repo.get(Semester, exam.semester_id)
    IO.inspect(semester)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "report_card.html",
        semester: semester,
        total_gpa: total_gpa,
        total_mark: total_mark,
        total_average: total_average,
        exam: exam,
        a: a,
        b: b,
        c: c,
        d: d,
        e: e,
        f: f,
        g: g,
        student_comment: student_comment,
        cgpa: cgpa,
        all_data: all_data,
        student_name: student_name,
        student_cname: student_cname,
        class_name: class_name,
        institution_name: institution.name,
        rank: student_rank,
        standard_rank: standard_rank,
        total_student: total_student,
        total_student_in_class: total_student_in_class
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8",
          "--orientation",
          "Portrait"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def all_report_card(conn, params) do
    # the format of class array is "exam_name/stu_id/rank - total_student"
    # the format of standard array is "exam_name/stu_id/class_rank - total_student - standard_rank - total_student_standard"
    student_data_lists = params["array"] |> String.split(",")

    exam_id =
      params["array"]
      |> String.split(",")
      |> hd
      |> String.split("/")
      |> List.to_tuple()
      |> elem(1)

    students =
      for list <- student_data_lists do
        exam_name = list |> String.split("/") |> List.to_tuple() |> elem(0)
        student_id = list |> String.split("/") |> List.to_tuple() |> elem(2)

        rank =
          list
          |> String.split("/")
          |> List.to_tuple()
          |> elem(3)
          |> String.split("-")
          |> List.to_tuple()
          |> elem(0)

        total_student =
          list
          |> String.split("/")
          |> List.to_tuple()
          |> elem(3)
          |> String.split("-")
          |> List.to_tuple()
          |> elem(1)

        {standard_rank, total_student_standard} =
          if list
             |> String.split("/")
             |> List.to_tuple()
             |> elem(3)
             |> String.split("-")
             |> Enum.count() == 4 do
            standard_rank =
              list
              |> String.split("/")
              |> List.to_tuple()
              |> elem(3)
              |> String.split("-")
              |> List.to_tuple()
              |> elem(2)

            total_student_standard =
              list
              |> String.split("/")
              |> List.to_tuple()
              |> elem(3)
              |> String.split("-")
              |> List.to_tuple()
              |> elem(3)

            {standard_rank, total_student_standard}
          else
            standard_rank = nil
            total_student_standard = nil

            {standard_rank, total_student_standard}
          end

        student =
          Repo.get_by(
            School.Affairs.Student,
            id: student_id,
            institution_id: conn.private.plug_session["institution_id"]
          )

        institution = Repo.get(Institution, conn.private.plug_session["institution_id"])

        exam =
          Repo.get_by(School.Affairs.ExamMaster, %{
            id: exam_id,
            institution_id: conn.private.plug_session["institution_id"]
          })

        student_comment = Repo.get_by(School.Affairs.StudentComment, student_id: student.id)

        all =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                em.student_id == ^student.id and e.name == ^exam_name and
                  sc.semester_id == ^exam.semester_id,
              select: %{
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                semester: j.id,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                standard_id: sc.level_id
              }
            )
          )

        all_data =
          for data <- all do
            grades =
              Repo.all(
                from(
                  g in School.Affairs.ExamGrade,
                  where:
                    g.institution_id == ^conn.private.plug_session["institution_id"] and
                      g.exam_master_id == ^exam.id
                )
              )

            for grade <- grades do
              if data.mark >= grade.min and data.mark <= grade.max do
                %{
                  class_name: data.class_name,
                  semester: data.semester,
                  student_name: data.student_name,
                  chinese_name: data.chinese_name,
                  grade: grade.name,
                  gpa: grade.gpa,
                  subject_code: data.subject_code,
                  subject_name: data.subject_name,
                  subject_cname: data.subject_cname,
                  student_mark: data.mark
                }
              end
            end
          end
          |> List.flatten()
          |> Enum.filter(fn x -> x != nil end)

        student_name = all_data |> Enum.map(fn x -> x.student_name end) |> Enum.uniq() |> hd
        student_cname = all_data |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd

        class_name = all_data |> Enum.map(fn x -> x.class_name end) |> Enum.uniq() |> hd

        a = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = all_data |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        per = all_data |> Enum.map(fn x -> x.student_mark end) |> Enum.count()
        total_mark = all_data |> Enum.map(fn x -> x.student_mark end) |> Enum.sum()
        total_gpa = all_data |> Enum.map(fn x -> Decimal.to_float(x.gpa) end) |> Enum.sum()
        cgpa = (total_gpa / per) |> Float.round(2)

        total_per = per * 100

        total_average = (total_mark / total_per * 100) |> Float.round(2)
        semester = Repo.get(Semester, exam.semester_id)

        %{
          semester: semester,
          total_gpa: total_gpa,
          total_mark: total_mark,
          total_average: total_average,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          f: f,
          g: g,
          cgpa: cgpa,
          exam: exam,
          all_data: all_data,
          student_name: student_name,
          student_cname: student_cname,
          class_name: class_name,
          student_comment: student_comment,
          institution_name: institution.name,
          rank: rank,
          total_student: total_student,
          total_student_standard: total_student_standard,
          standard_rank: standard_rank
        }
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "all_report_card.html",
        students: students
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8",
          "--orientation",
          "Portrait"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  defp get_class_rank(clas_rank, student_id, class_name) do
    class_rank =
      clas_rank
      |> Enum.filter(fn x -> x |> elem(2) == class_name end)
      |> Enum.sort_by(fn x -> x |> elem(1) end)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.filter(fn x -> x |> elem(0) |> elem(0) == student_id end)
      |> Enum.map(fn x -> x |> elem(1) end)
      |> hd

    class_rank = class_rank + 1
  end

  defp get_total_student_class(clas_rank, class_name) do
    total_student_class =
      clas_rank
      |> Enum.filter(fn x -> x |> elem(2) == class_name end)
      |> Enum.count()

    total_student_class = total_student_class
  end

  def all_exam_report_card(conn, params) do
    class = Repo.get_by(School.Affairs.Class, id: params["class"])

    list_exam =
      Repo.all(from(s in School.Affairs.ExamMaster, where: s.level_id == ^class.level_id))

    list_stu =
      for item <- list_exam do
        all =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where: e.id == ^item.id and sc.semester_id == ^item.semester_id,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                standard_id: sc.level_id
              }
            )
          )

        {item.name, all}
      end

    all_data =
      for data <- list_stu do
        data = data |> elem(1)

        deep =
          for item <- data do
            grades =
              Repo.all(
                from(
                  g in School.Affairs.ExamGrade,
                  where:
                    g.institution_id == ^conn.private.plug_session["institution_id"] and
                      g.exam_master_id == ^item.exam_master_id
                )
              )

            a =
              for grade <- grades do
                if item.mark >= grade.min and item.mark <= grade.max do
                  %{
                    exam_master_id: item.exam_master_id,
                    exam_name: item.exam_name,
                    class_name: item.class_name,
                    semester: item.semester,
                    student_id: item.student_id,
                    student_name: item.student_name,
                    chinese_name: item.chinese_name,
                    grade: grade.name,
                    gpa: grade.gpa,
                    subject_code: item.subject_code,
                    subject_name: item.subject_name,
                    subject_cname: item.subject_cname,
                    student_mark: item.mark
                  }
                end
              end

            a
          end

        stdu_rank =
          deep
          |> List.flatten()
          |> Enum.filter(fn x -> x != nil end)
          |> Enum.group_by(fn x -> x.student_id end)

        std_rank =
          for item <- stdu_rank do
            id = item |> elem(0)
            sum = item |> elem(1) |> Enum.map(fn x -> x.student_mark end) |> Enum.sum()

            {id, sum}
          end
          |> Enum.sort_by(fn x -> x |> elem(1) end)
          |> Enum.reverse()
          |> Enum.with_index()

        clas_rank =
          for item <- stdu_rank do
            id = item |> elem(0)

            sum = item |> elem(1) |> Enum.map(fn x -> x.student_mark end) |> Enum.sum()

            class_name =
              item |> elem(1) |> Enum.map(fn x -> x.class_name end) |> Enum.uniq() |> hd

            {id, sum, class_name}
          end

        for item <- std_rank do
          no = item |> elem(1)
          item = item |> elem(0)

          no = no + 1

          stud =
            deep
            |> List.flatten()
            |> Enum.filter(fn x -> x != nil end)
            |> Enum.filter(fn x -> x.student_id == item |> elem(0) end)

          total_student = std_rank |> Enum.count()

          with_rank =
            for item <- stud do
              %{
                exam_master_id: item.exam_master_id,
                exam_name: item.exam_name,
                class_name: item.class_name,
                semester: item.semester,
                student_id: item.student_id,
                student_name: item.student_name,
                chinese_name: item.chinese_name,
                grade: item.grade,
                gpa: item.gpa,
                subject_code: item.subject_code,
                subject_name: item.subject_name,
                subject_cname: item.subject_cname,
                student_mark: item.student_mark,
                stand_rank: no,
                class_rank: get_class_rank(clas_rank, item.student_id, item.class_name),
                total_student: total_student,
                total_student_class: get_total_student_class(clas_rank, item.class_name)
              }
            end

          with_rank
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    list =
      all_data
      |> Enum.group_by(fn x -> x.student_id end)

    good =
      for item <- list do
        student_id = item |> elem(0)
        item = item |> elem(1)

        student_name = item |> Enum.map(fn x -> x.student_name end) |> Enum.uniq() |> hd
        student_cname = item |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd
        class_name = item |> Enum.map(fn x -> x.class_name end) |> Enum.uniq() |> hd

        total_student = item |> Enum.map(fn x -> x.total_student end) |> Enum.uniq() |> hd

        total_student_class =
          item |> Enum.map(fn x -> x.total_student_class end) |> Enum.uniq() |> hd

        student_comment = Repo.get_by(School.Affairs.StudentComment, student_id: student_id)

        group_exam = item |> Enum.group_by(fn x -> x.exam_master_id end)

        for item <- group_exam do
          exam_master_id = item |> elem(0)
          record = item |> elem(1)

          stand_rank = record |> Enum.map(fn x -> x.stand_rank end) |> Enum.uniq() |> hd

          class_rank = record |> Enum.map(fn x -> x.class_rank end) |> Enum.uniq() |> hd

          institution = Repo.get(Institution, conn.private.plug_session["institution_id"])
          exam = Repo.get_by(School.Affairs.ExamMaster, id: exam_master_id)

          semester = Repo.get_by(School.Affairs.Semester, id: exam.semester_id)
          a = record |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
          b = record |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
          c = record |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
          d = record |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
          e = record |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
          f = record |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
          g = record |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

          per = record |> Enum.map(fn x -> x.student_mark end) |> Enum.count()
          total_mark = record |> Enum.map(fn x -> x.student_mark end) |> Enum.sum()
          total_gpa = record |> Enum.map(fn x -> Decimal.to_float(x.gpa) end) |> Enum.sum()
          cgpa = (total_gpa / per) |> Float.round(2)

          total_per = per * 100

          total_average = (total_mark / total_per * 100) |> Float.round(2)

          %{
            list_exam: list_exam,
            semester: semester,
            total_gpa: total_gpa,
            total_mark: total_mark,
            total_average: total_average,
            a: a,
            b: b,
            c: c,
            d: d,
            e: e,
            f: f,
            g: g,
            cgpa: cgpa,
            exam: exam,
            all_data: record,
            student_name: student_name,
            student_cname: student_cname,
            class_name: class_name,
            student_comment: student_comment,
            institution_name: institution.name,
            rank: stand_rank,
            class_rank: class_rank,
            total_student: total_student,
            total_student_class: total_student_class
          }
        end
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ExamView,
        "all_exam_report_card.html",
        students: good
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8",
          "--orientation",
          "Portrait"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def generate_ranking(conn, params) do
    exam =
      Repo.all(from(e in School.Affairs.ExamMaster))
      |> Enum.map(fn x -> %{name: x.name} end)
      |> Enum.uniq()

    level = Repo.all(from(l in School.Affairs.Level))
    semester = Repo.all(from(s in School.Affairs.Semester))

    render(conn, "generate_ranking.html", semester: semester, level: level, exam: exam)
  end

  def exam_ranking(conn, params) do
    exam_name = params["exam_name"]
    level_id = params["level_id"]
    semester_id = params["semester_id"]

    exam_id =
      Repo.get_by(School.Affairs.ExamMaster, %{
        name: exam_name,
        level_id: level_id,
        semester_id: semester_id
      })

    if exam_id == nil do
      conn
      |> put_flash(:info, "This level do not have any exam data")
      |> redirect(to: exam_path(conn, :generate_ranking))
    end

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
            e.exam_id == ^exam_id.id and k.semester_id == ^semester_id and k.level_id == ^level_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            class_id: e.class_id
          }
        )
      )

    if exam_mark != [] do
      exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd

      all_mark = exam_mark |> Enum.group_by(fn x -> x.subject_code end)

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
                  where: g.institution_id == ^conn.private.plug_session["institution_id"]
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
                  class_id: data.class_id
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
          total = new |> elem(1) |> Enum.map(fn x -> x.student_mark end) |> Enum.sum()

          per = new |> elem(1) |> Enum.map(fn x -> x.student_mark end) |> Enum.count()
          total_per = per * 100

          total_average = (total / total_per * 100) |> Float.round(2)

          class_id = new |> elem(1) |> Enum.map(fn x -> x.class_id end) |> Enum.uniq() |> hd
          student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd

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

      render(conn, "exam_ranking.html", z: t, exam_name: exam_name, mark: mark, mark1: mark1)
    else
      conn
      |> put_flash(:info, "Please Insert Exam Record First")
      |> redirect(to: class_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    exam = Affairs.get_exam!(id)
    render(conn, "show.html", exam: exam)
  end

  def edit(conn, %{"id" => id}) do
    exam = Affairs.get_exam!(id)
    changeset = Affairs.change_exam(exam)
    render(conn, "edit.html", exam: exam, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exam" => exam_params}) do
    exam = Affairs.get_exam!(id)

    case Affairs.update_exam(exam, exam_params) do
      {:ok, exam} ->
        conn
        |> put_flash(:info, "Exam updated successfully.")
        |> redirect(to: exam_path(conn, :show, exam))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", exam: exam, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exam = Affairs.get_exam!(id)
    {:ok, _exam} = Affairs.delete_exam(exam)

    conn
    |> put_flash(:info, "Exam deleted successfully.")
    |> redirect(to: exam_path(conn, :index))
  end

  def history_report_card(conn, params) do
    all =
      Repo.all(
        from(s in Affairs.MarkSheetHistorys,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{year: s.year, class: s.class}
        )
      )

    year =
      all
      |> Enum.map(fn x -> x.year end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != nil end)

    class_name =
      all
      |> Enum.map(fn x -> x.class end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != nil end)

    render(conn, "history_report_card.html",
      year: year,
      class_name: class_name
    )
  end
end

# {{4696, 429}, 0},
# {{4726, 408}, 1},
# {{4717, 400}, 2},
# {{4640, 397}, 3},
# {{4736, 396}, 4},
# {{4688, 384}, 5},
# {{4737, 374}, 6},
# {{4563, 356}, 7}

# {{4717, 457}, 0},
# {{4640, 449}, 1},
# {{4563, 436}, 2},
# {{4726, 411}, 3},
# {{4737, 395}, 4},
# {{4736, 384}, 5},
# {{4696, 384}, 6},
# {{4688, 343}, 7}
