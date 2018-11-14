defmodule SchoolWeb.ExamPeriodController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ExamPeriod
  require IEx

  def index(conn, _params) do
    examperiod = Affairs.list_examperiod()
    render(conn, "index.html", examperiod: examperiod)
  end

  def show_exam_period(conn, params) do
    exam_details =
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
          left_join: ep in ExamPeriod,
          on: ep.exam_id == e.id,
          where:
            em.institution_id == ^conn.private.plug_session["institution_id"] and
              sm.id == ^params["semester_id"] and em.name == ^params["exam_name"],
          select: %{
            start_date: ep.start_date,
            end_date: ep.end_date,
            exam_name: em.name,
            semester: sm.start_date,
            subject: s.description
          }
        )
      )

    exam_name =
      exam_details |> Enum.group_by(fn x -> x.exam_name end) |> Map.keys() |> List.to_string()

    semester = exam_details |> Enum.group_by(fn x -> x.semester end) |> Map.keys() |> List.first()

    changeset = Affairs.change_exam_period(%ExamPeriod{})

    render(
      conn,
      "show_exam_period.html",
      changeset: changeset,
      exam_details: exam_details,
      exam_name: exam_name,
      semester: semester
    )
  end

  def new(conn, _params) do
    changeset = Affairs.change_exam_period(%ExamPeriod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"exam_period" => exam_period_params}) do
    case Affairs.create_exam_period(exam_period_params) do
      {:ok, exam_period} ->
        conn
        |> put_flash(:info, "Exam period created successfully.")
        |> redirect(to: exam_period_path(conn, :show, exam_period))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    exam_period = Affairs.get_exam_period!(id)
    render(conn, "show.html", exam_period: exam_period)
  end

  def edit(conn, %{"id" => id}) do
    exam_period = Affairs.get_exam_period!(id)
    changeset = Affairs.change_exam_period(exam_period)
    render(conn, "edit.html", exam_period: exam_period, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exam_period" => exam_period_params}) do
    exam_period = Affairs.get_exam_period!(id)

    case Affairs.update_exam_period(exam_period, exam_period_params) do
      {:ok, exam_period} ->
        conn
        |> put_flash(:info, "Exam period updated successfully.")
        |> redirect(to: exam_period_path(conn, :show, exam_period))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", exam_period: exam_period, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exam_period = Affairs.get_exam_period!(id)
    {:ok, _exam_period} = Affairs.delete_exam_period(exam_period)

    conn
    |> put_flash(:info, "Exam period deleted successfully.")
    |> redirect(to: exam_period_path(conn, :index))
  end
end