defmodule SchoolWeb.AssessmentMarkController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.AssessmentMark

  def index(conn, _params) do
    assessment_mark = Affairs.list_assessment_mark()
    render(conn, "index.html", assessment_mark: assessment_mark)
  end

  def assessment_report(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    classes =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    render(conn, "assessment_report.html", semesters: semesters, classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_assessment_mark(%AssessmentMark{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"assessment_mark" => assessment_mark_params}) do
    case Affairs.create_assessment_mark(assessment_mark_params) do
      {:ok, assessment_mark} ->
        conn
        |> put_flash(:info, "Assessment mark created successfully.")
        |> redirect(to: assessment_mark_path(conn, :show, assessment_mark))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    assessment_mark = Affairs.get_assessment_mark!(id)
    render(conn, "show.html", assessment_mark: assessment_mark)
  end

  def edit(conn, %{"id" => id}) do
    assessment_mark = Affairs.get_assessment_mark!(id)
    changeset = Affairs.change_assessment_mark(assessment_mark)
    render(conn, "edit.html", assessment_mark: assessment_mark, changeset: changeset)
  end

  def update(conn, %{"id" => id, "assessment_mark" => assessment_mark_params}) do
    assessment_mark = Affairs.get_assessment_mark!(id)

    case Affairs.update_assessment_mark(assessment_mark, assessment_mark_params) do
      {:ok, assessment_mark} ->
        conn
        |> put_flash(:info, "Assessment mark updated successfully.")
        |> redirect(to: assessment_mark_path(conn, :show, assessment_mark))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", assessment_mark: assessment_mark, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    assessment_mark = Affairs.get_assessment_mark!(id)
    {:ok, _assessment_mark} = Affairs.delete_assessment_mark(assessment_mark)

    conn
    |> put_flash(:info, "Assessment mark deleted successfully.")
    |> redirect(to: assessment_mark_path(conn, :index))
  end
end
