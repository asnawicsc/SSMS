defmodule SchoolWeb.SemesterController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Semester

  def index(conn, _params) do
    semesters = Affairs.list_semesters()
    render(conn, "index.html", semesters: semesters)
  end

  def new(conn, _params) do
    changeset = Affairs.change_semester(%Semester{start_date: Timex.today, end_date: Timex.today, holiday_start: Timex.today, holiday_end: Timex.today})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"semester" => semester_params}) do
    case Affairs.create_semester(semester_params) do
      {:ok, semester} ->
        conn
        |> put_flash(:info, "Semester created successfully.")
        |> redirect(to: semester_path(conn, :show, semester))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    semester = Affairs.get_semester!(id)
    render(conn, "show.html", semester: semester)
  end

  def edit(conn, %{"id" => id}) do
    semester = Affairs.get_semester!(id)
    changeset = Affairs.change_semester(semester)
    render(conn, "edit.html", semester: semester, changeset: changeset)
  end

  def update(conn, %{"id" => id, "semester" => semester_params}) do
    semester = Affairs.get_semester!(id)

    case Affairs.update_semester(semester, semester_params) do
      {:ok, semester} ->
        conn
        |> put_flash(:info, "Semester updated successfully.")
        |> redirect(to: semester_path(conn, :show, semester))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", semester: semester, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    semester = Affairs.get_semester!(id)
    {:ok, _semester} = Affairs.delete_semester(semester)

    conn
    |> put_flash(:info, "Semester deleted successfully.")
    |> redirect(to: semester_path(conn, :index))
  end
end