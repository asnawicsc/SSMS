defmodule SchoolWeb.ExamGradeController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ExamGrade
  alias School.Affairs.ExamMaster
  alias School.Affairs.Semester
  alias School.Affairs.Level

  require IEx

  def index(conn, _params) do
    exam_grade = Affairs.list_exam_grade()
    render(conn, "index.html", exam_grade: exam_grade)
  end

  def new(conn, _params) do
    changeset = Affairs.change_exam_grade(%ExamGrade{})
    render(conn, "new.html", changeset: changeset)
  end

  def add_grade(conn, params) do
    changeset = Affairs.change_exam_grade(%ExamGrade{})

    render(conn, "new_grade.html", changeset: changeset, exam_master_id: params["exam_master_id"])
  end

  def add_exam_grade(conn, params) do
    exam_master_id = params["exam_master_id"]
    grade = params["grade"]

    exist =
      Repo.all(
        from(e in ExamGrade,
          where:
            e.institution_id == ^conn.private.plug_session["institution_id"] and e.name == ^grade and
              e.exam_master_id == ^exam_master_id
        )
      )

    if exist == [] do
      exam_grade_params = %{
        exam_master_id: params["exam_master_id"],
        name: params["grade"],
        min: params["min"],
        max: params["max"],
        gpa: params["gpa"],
        institution_id: conn.private.plug_session["institution_id"]
      }

      Affairs.create_exam_grade(exam_grade_params)

      conn
      |> put_flash(:info, "Exam grade created successfully.")
      |> redirect(to: exam_path(conn, :index))
    else
      conn
      |> put_flash(:info, "Fail to create,grade already exist.")
      |> redirect(to: exam_path(conn, :index))
    end
  end

  def show_exam_grade(conn, params) do
    exam_details =
      Repo.all(
        from(
          e in ExamGrade,
          left_join: em in ExamMaster,
          on: em.id == e.exam_master_id,
          left_join: sm in Semester,
          on: em.semester_id == sm.id,
          left_join: l in Level,
          on: em.level_id == l.id,
          where:
            em.institution_id == ^conn.private.plug_session["institution_id"] and
              e.institution_id == ^conn.private.plug_session["institution_id"] and
              sm.id == ^params["semester_id"] and em.id == ^params["exam_name"] and
              em.level_id == ^params["level"],
          select: %{
            name: e.name,
            min: e.min,
            max: e.max,
            gpa: e.gpa,
            id: e.id
          }
        )
      )

    exam_master_id =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: params["exam_name"],
        semester_id: params["semester_id"],
        level_id: params["level"]
      })

    render(
      conn,
      "show_exam_grade.html",
      exam_master_id: exam_master_id,
      exam_details: exam_details
    )
  end

  def default_grade(conn, params) do
    Repo.delete_all(
      from(s in School.Affairs.ExamGrade,
        where:
          s.institution_id == ^conn.private.plug_session["institution_id"] and
            s.exam_master_id == ^params["exam_master_id"]
      )
    )

    Affairs.create_exam_grade(%{
      name: "A",
      min: 80.9,
      max: 100,
      gpa: 12.00,
      exam_master_id: params["exam_master_id"],
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_exam_grade(%{
      name: "B",
      min: 60.9,
      max: 79.9,
      gpa: 8.00,
      exam_master_id: params["exam_master_id"],
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_exam_grade(%{
      name: "C",
      min: 50.9,
      max: 59.9,
      gpa: 6.00,
      exam_master_id: params["exam_master_id"],
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_exam_grade(%{
      name: "D",
      min: 40.9,
      max: 49.9,
      gpa: 4.00,
      exam_master_id: params["exam_master_id"],
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_exam_grade(%{
      name: "E",
      min: 0,
      max: 39.9,
      gpa: 2.00,
      exam_master_id: params["exam_master_id"],
      institution_id: conn.private.plug_session["institution_id"]
    })

    conn
    |> put_flash(:info, "Exame Grade updated successfully.")
    |> redirect(to: exam_path(conn, :index))
  end

  def create(conn, %{"exam_grade" => exam_grade_params}) do
    case Affairs.create_exam_grade(exam_grade_params) do
      {:ok, exam_grade} ->
        conn
        |> put_flash(:info, "Exam grade created successfully.")
        |> redirect(to: exam_grade_path(conn, :show, exam_grade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    exam_grade = Affairs.get_exam_grade!(id)
    render(conn, "show.html", exam_grade: exam_grade)
  end

  def edit(conn, %{"id" => id}) do
    exam_grade = Affairs.get_exam_grade!(id)
    changeset = Affairs.change_exam_grade(exam_grade)
    render(conn, "edit.html", exam_grade: exam_grade, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exam_grade" => exam_grade_params}) do
    exam_grade = Affairs.get_exam_grade!(id)

    case Affairs.update_exam_grade(exam_grade, exam_grade_params) do
      {:ok, exam_grade} ->
        conn
        |> put_flash(:info, "Exam grade updated successfully.")
        |> redirect(to: exam_grade_path(conn, :show, exam_grade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", exam_grade: exam_grade, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exam_grade = Affairs.get_exam_grade!(id)
    {:ok, _exam_grade} = Affairs.delete_exam_grade(exam_grade)

    conn
    |> put_flash(:info, "Exam grade deleted successfully.")
    |> redirect(to: exam_grade_path(conn, :index))
  end
end
