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
                  p.semester_id == ^conn.private.plug_session["semester_id"] and s.is_delete == 0,
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

    assessment_subject = Repo.get_by(School.Affairs.AssessmentSubject, id: assessment_id)

    class = Repo.get_by(School.Affairs.Class, id: class_id)

    subject = Repo.get_by(School.Affairs.Subject, id: subject_id)

    level1 = assessment_subject.level1
    level2 = assessment_subject.level2
    level3 = assessment_subject.level3
    level4 = assessment_subject.level4
    level5 = assessment_subject.level5
    level6 = assessment_subject.level6

    level = [
      %{id: 1, desc: level1},
      %{id: 2, desc: level2},
      %{id: 3, desc: level3},
      %{id: 4, desc: level4},
      %{id: 5, desc: level5},
      %{id: 6, desc: level6}
    ]

    exist =
      Repo.all(
        from(s in School.Affairs.AssessmentMark,
          where:
            s.class_id == ^class_id and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"] and
              s.subject_id == ^subject_id and s.assessment_subject_id == ^assessment_id
        )
      )

    if exist == [] do
      students =
        Repo.all(
          from(
            s in Student,
            left_join: c in StudentClass,
            on: c.sudent_id == s.id,
            where:
              c.class_id == ^class_id and
                c.semester_id == ^conn.private.plug_session["semester_id"] and
                s.institution_id == ^conn.private.plug_session["institution_id"],
            order_by: [asc: s.name],
            select: %{
              id: s.id,
              name: s.name,
              chinese_name: s.chinese_name
            }
          )
        )

      if students == [] do
        conn
        |> put_flash(:info, "No Student In the Class")
        |> redirect(to: assessment_subject_path(conn, :assign_level))
      else
        render(
          conn,
          "generate_rules_break.html",
          students: students,
          assessment_subject: assessment_subject,
          class: class,
          subject: subject,
          level: level
        )
      end
    else
      render(
        conn,
        "edit_rules_break.html",
        exist: exist,
        assessment_subject: assessment_subject,
        class: class,
        subject: subject,
        level: level
      )
    end
  end

  def create_rules_break(conn, params) do
    assessment_subject_id = params["assessment_subject_id"]
    class_id = params["class_id"]
    subject_id = params["subject_id"]

    student = params["student"]

    for item <- student do
      student_id = item |> elem(0)
      level = item |> elem(1)

      assessment_subject =
        Repo.get_by(Affairs.AssessmentSubject,
          id: assessment_subject_id,
          institution_id: conn.private.plug_session["institution_id"]
        )

      level1 = assessment_subject.level1
      level2 = assessment_subject.level2
      level3 = assessment_subject.level3
      level4 = assessment_subject.level4
      level5 = assessment_subject.level5
      level6 = assessment_subject.level6

      assessment_subject_level_desc =
        case level do
          "1" ->
            level1

          "2" ->
            level2

          "3" ->
            level3

          "4" ->
            level4

          "5" ->
            level5

          "6" ->
            level6
        end

      assessment_mark_params = %{
        class_id: String.to_integer(class_id),
        institution_id: conn.private.plug_session["institution_id"],
        semester_id: conn.private.plug_session["semester_id"],
        standard_id: assessment_subject.standard_id,
        subject_id: String.to_integer(subject_id),
        assessment_subject_id: String.to_integer(assessment_subject_id),
        student_id: String.to_integer(student_id),
        assessment_subject_level: String.to_integer(level),
        assessment_subject_level_desc: assessment_subject_level_desc
      }

      Affairs.create_assessment_mark(assessment_mark_params)
    end

    conn
    |> put_flash(:info, "Assessment mark created successfully.")
    |> redirect(to: assessment_subject_path(conn, :assign_level))
  end

  def edit_rules_break(conn, params) do
    assessment_subject_id = params["assessment_subject_id"]
    class_id = params["class_id"]
    subject_id = params["subject_id"]

    student = params["student"]

    for item <- student do
      student_id = item |> elem(0)
      level = item |> elem(1)

      assessment_subject =
        Repo.get_by(Affairs.AssessmentSubject,
          id: assessment_subject_id,
          institution_id: conn.private.plug_session["institution_id"]
        )

      level1 = assessment_subject.level1
      level2 = assessment_subject.level2
      level3 = assessment_subject.level3
      level4 = assessment_subject.level4
      level5 = assessment_subject.level5
      level6 = assessment_subject.level6

      assessment_subject_level_desc =
        case level do
          "1" ->
            level1

          "2" ->
            level2

          "3" ->
            level3

          "4" ->
            level4

          "5" ->
            level5

          "6" ->
            level6
        end

      assessment_mark =
        Repo.get_by(Affairs.AssessmentMark,
          class_id: String.to_integer(class_id),
          institution_id: conn.private.plug_session["institution_id"],
          semester_id: conn.private.plug_session["semester_id"],
          standard_id: assessment_subject.standard_id,
          subject_id: String.to_integer(subject_id),
          assessment_subject_id: String.to_integer(assessment_subject_id),
          student_id: String.to_integer(student_id)
        )

      assessment_mark_params = %{
        class_id: String.to_integer(class_id),
        institution_id: conn.private.plug_session["institution_id"],
        semester_id: conn.private.plug_session["semester_id"],
        standard_id: assessment_subject.standard_id,
        subject_id: String.to_integer(subject_id),
        assessment_subject_id: String.to_integer(assessment_subject_id),
        student_id: String.to_integer(student_id),
        assessment_subject_level: String.to_integer(level),
        assessment_subject_level_desc: assessment_subject_level_desc
      }

      Affairs.update_assessment_mark(assessment_mark, assessment_mark_params)
    end

    conn
    |> put_flash(:info, "Assessment mark updated successfully.")
    |> redirect(to: assessment_subject_path(conn, :assign_level))
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
