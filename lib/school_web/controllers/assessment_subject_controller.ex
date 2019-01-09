defmodule SchoolWeb.AssessmentSubjectController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.AssessmentSubject
  require IEx

  def index(conn, _params) do
    assessment_subject = Affairs.list_assessment_subject()
    render(conn, "index.html", assessment_subject: assessment_subject)
  end

  def generate_assessment_subject(conn, params) do
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

    render(conn, "generate_assessment_subject.html",
      subjects: subjects,
      semester: semester,
      level: levels
    )
  end

  def create_assessment_subject(conn, params) do
    level_id = params["level"]
    semester_id = params["semester"]
    institution_id = conn.private.plug_session["institution_id"]

    subjects = params["subject"] |> String.split(",")

    for subject <- subjects do
      assessment_subject_params = %{
        standard_id: level_id,
        semester_id: semester_id,
        institution_id: institution_id,
        subject_id: subject
      }

      Affairs.create_assessment_subject(assessment_subject_params)
    end

    conn
    |> put_flash(:info, "Assessment Subjecr created successfully.")
    |> redirect(to: assessment_subject_path(conn, :index))
  end

  def assign_level(conn, params) do
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
              p in School.Affairs.AssessmentSubject,
              left_join: m in School.Affairs.Semester,
              on: m.id == p.semester_id,
              left_join: q in School.Affairs.Level,
              on: q.id == p.standard_id,
              left_join: g in School.Affairs.Subject,
              on: g.id == p.subject_id,
              left_join: s in School.Affairs.Class,
              on: q.id == s.level_id,
              where:
                p.institution_id == ^conn.private.plug_session["institution_id"] and
                  m.institution_id == ^conn.private.plug_session["institution_id"] and
                  q.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.institution_id == ^conn.private.plug_session["institution_id"] and
                  p.semester_id == ^conn.private.plug_session["semester_id"],
              select: %{
                id: p.id,
                subject_id: g.subject_id,
                class_id: g.class_id,
                class: s.name,
                subject: g.description
              }
            )
          )

        {class, a}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        class =
          Repo.all(
            from(
              p in School.Affairs.Period,
              left_join: s in School.Affairs.Class,
              on: s.id == p.class_id,
              where:
                s.institution_id == ^conn.private.plug_session["institution_id"] and
                  p.teacher_id == ^teacher.id,
              select: %{id: s.id, name: s.name}
            )
          )
          |> Enum.uniq()

        a =
          Repo.all(
            from(
              p in School.Affairs.AssessmentSubject,
              left_join: h in School.Affairs.Period,
              on: h.subject_id == p.subject_id,
              left_join: m in School.Affairs.Semester,
              on: m.id == p.semester_id,
              left_join: q in School.Affairs.Level,
              on: q.id == p.standard_id,
              left_join: g in School.Affairs.Subject,
              on: g.id == p.subject_id,
              left_join: s in School.Affairs.Class,
              on: q.id == s.level_id,
              where:
                h.class_id == s.id and h.teacher_id == ^teacher.id and
                  p.institution_id == ^conn.private.plug_session["institution_id"] and
                  m.institution_id == ^conn.private.plug_session["institution_id"] and
                  q.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.institution_id == ^conn.private.plug_session["institution_id"] and
                  p.semester_id == ^conn.private.plug_session["semester_id"],
              select: %{
                id: p.id,
                subject_id: g.id,
                class_id: s.id,
                class: s.name,
                subject: g.description
              }
            )
          )

        {class, a}
      end

    if class == [] do
      conn
      |> put_flash(:info, "You Dont Teach Any Subject.")
      |> redirect(to: page_path(conn, :dashboard))
    else
      render(conn, "assign_level.html", class: class, a: a)
    end
  end

  def generate_rules_break(conn, params) do
    subject_id = params["subject_id"]
    class_id = params["class_id"]
    assessment_id = params["assessment_id"]

    IEx.pry()

    # exam = Repo.get_by(School.Affairs.Exam, %{id: exam_id, subject_id: subject_id})
    # exam_master = Repo.get_by(School.Affairs.ExamMaster, id: exam.exam_master_id)

    # all =
    #   Repo.all(
    #     from(
    #       s in School.Affairs.ExamMark,
    #       where:
    #         s.class_id == ^class_id and s.subject_id == ^subject_id and s.exam_id == ^exam_id,
    #       select: %{
    #         class_id: s.class_id,
    #         subject_id: s.subject_id,
    #         exam_id: s.exam_id,
    #         student_id: s.student_id,
    #         mark: s.mark
    #       }
    #     )
    #   )

    # if all == [] do
    #   class =
    #     Repo.get_by(School.Affairs.Class, %{
    #       id: class_id,
    #       institution_id: conn.private.plug_session["institution_id"]
    #     })

    #   subject =
    #     Repo.get_by(School.Affairs.Subject, %{
    #       id: subject_id,
    #       institution_id: conn.private.plug_session["institution_id"]
    #     })

    #   verify =
    #     Repo.all(
    #       from(
    #         s in School.Affairs.Period,
    #         where: s.class_id == ^class.id and s.subject_id == ^subject.id,
    #         select: %{teacher_id: s.teacher_id}
    #       )
    #     )

    #   student =
    #     Repo.all(
    #       from(
    #         s in School.Affairs.StudentClass,
    #         left_join: p in Student,
    #         on: p.id == s.sudent_id,
    #         where:
    #           s.class_id == ^class.id and
    #             p.institution_id == ^conn.private.plug_session["institution_id"] and
    #             s.semester_id == ^exam_master.semester_id,
    #         select: %{id: p.id, student_name: p.name}
    #       )
    #     )

    #   if student == [] do
    #     conn
    #     |> put_flash(:info, "No Student in the Class,Please Enroll Student to Class first.")
    #     |> redirect(to: exam_path(conn, :mark_sheet))
    #   else
    #     render(
    #       conn,
    #       "mark.html",
    #       all: all,
    #       student: student,
    #       class: class,
    #       subject: subject,
    #       exam_id: exam_id
    #     )
    #   end
    # else
    #   class =
    #     Repo.get_by(School.Affairs.Class, %{
    #       id: class_id,
    #       institution_id: conn.private.plug_session["institution_id"]
    #     })

    #   exam_id = params["id"]

    #   subject =
    #     Repo.get_by(School.Affairs.Subject, %{
    #       id: subject_id,
    #       institution_id: conn.private.plug_session["institution_id"]
    #     })

    #   # all_student=Repo.all(from s in School.Affairs.StudentClass,   
    #   #   where: e.subject_id==^subject.id and s.class_id==^class.id and e.exam_id==^exam_id and e.student_id != s.sudent_id,
    #   #   select: %{
    #   #     name: s.sudent_id,
    #   #     mark: e.mark
    #   #     })
    #   t =
    #     Repo.all(
    #       from(
    #         s in School.Affairs.StudentClass,
    #         left_join: p in Student,
    #         on: p.id == s.sudent_id,
    #         where:
    #           s.class_id == ^class.id and
    #             p.institution_id == ^conn.private.plug_session["institution_id"] and
    #             s.semester_id == ^exam_master.semester_id,
    #         select: %{id: p.id, student_name: p.name}
    #       )
    #     )

    #   fi =
    #     for item <- t do
    #       a = Enum.filter(all, fn x -> x.student_id == item.id end)

    #       if a == [] do
    #         %{
    #           class_id: class_id,
    #           exam_id: exam_id,
    #           student_id: item.id,
    #           subject_id: subject_id,
    #           student_name: item.student_name,
    #           mark: 0
    #         }
    #       else
    #       end
    #     end
    #     |> Enum.filter(fn x -> x != nil end)

    #   # csrf = Phoenix.Controller.get_csrf_token()

    #   # {Phoenix.View.render_to_string(
    #   #    SchoolWeb.ExamView,
    #   #    "edit_mark.html",
    #   #    all: all,
    #   #    fi: fi,
    #   #    class: class,
    #   #    exam_id: exam_id,
    #   #    subject: subject,

    #   #  )}

    #   render(
    #     conn,
    #     "edit_mark.html",
    #     all: all,
    #     fi: fi,
    #     class: class,
    #     exam_id: exam_id,
    #     subject: subject
    #   )
    # end
  end

  def new(conn, _params) do
    changeset = Affairs.change_assessment_subject(%AssessmentSubject{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"assessment_subject" => assessment_subject_params}) do
    case Affairs.create_assessment_subject(assessment_subject_params) do
      {:ok, assessment_subject} ->
        conn
        |> put_flash(:info, "Assessment subject created successfully.")
        |> redirect(to: assessment_subject_path(conn, :show, assessment_subject))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    assessment_subject = Affairs.get_assessment_subject!(id)
    render(conn, "show.html", assessment_subject: assessment_subject)
  end

  def edit(conn, %{"id" => id}) do
    assessment_subject = Affairs.get_assessment_subject!(id)
    changeset = Affairs.change_assessment_subject(assessment_subject)
    render(conn, "edit.html", assessment_subject: assessment_subject, changeset: changeset)
  end

  def update(conn, %{"id" => id, "assessment_subject" => assessment_subject_params}) do
    assessment_subject = Affairs.get_assessment_subject!(id)

    case Affairs.update_assessment_subject(assessment_subject, assessment_subject_params) do
      {:ok, assessment_subject} ->
        conn
        |> put_flash(:info, "Assessment subject updated successfully.")
        |> redirect(to: assessment_subject_path(conn, :show, assessment_subject))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", assessment_subject: assessment_subject, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    assessment_subject = Affairs.get_assessment_subject!(id)
    {:ok, _assessment_subject} = Affairs.delete_assessment_subject(assessment_subject)

    conn
    |> put_flash(:info, "Assessment subject deleted successfully.")
    |> redirect(to: assessment_subject_path(conn, :index))
  end
end
