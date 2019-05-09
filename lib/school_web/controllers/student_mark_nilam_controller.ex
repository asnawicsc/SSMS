defmodule SchoolWeb.StudentMarkNilamController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.StudentMarkNilam

  def index(conn, _params) do
    student_mark_nilam = Affairs.list_student_mark_nilam()
    render(conn, "index.html", student_mark_nilam: student_mark_nilam)
  end

  def new(conn, _params) do
    changeset = Affairs.change_student_mark_nilam(%StudentMarkNilam{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"student_mark_nilam" => student_mark_nilam_params}) do
    case Affairs.create_student_mark_nilam(student_mark_nilam_params) do
      {:ok, student_mark_nilam} ->
        conn
        |> put_flash(:info, "Student mark nilam created successfully.")
        |> redirect(to: student_mark_nilam_path(conn, :show, student_mark_nilam))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    student_mark_nilam = Affairs.get_student_mark_nilam!(id)
    render(conn, "show.html", student_mark_nilam: student_mark_nilam)
  end

  def edit(conn, %{"id" => id}) do
    student_mark_nilam = Affairs.get_student_mark_nilam!(id)
    changeset = Affairs.change_student_mark_nilam(student_mark_nilam)
    render(conn, "edit.html", student_mark_nilam: student_mark_nilam, changeset: changeset)
  end

  def update(conn, %{"id" => id, "student_mark_nilam" => student_mark_nilam_params}) do
    student_mark_nilam = Affairs.get_student_mark_nilam!(id)

    case Affairs.update_student_mark_nilam(student_mark_nilam, student_mark_nilam_params) do
      {:ok, student_mark_nilam} ->
        conn
        |> put_flash(:info, "Student mark nilam updated successfully.")
        |> redirect(to: student_mark_nilam_path(conn, :show, student_mark_nilam))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", student_mark_nilam: student_mark_nilam, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    student_mark_nilam = Affairs.get_student_mark_nilam!(id)
    {:ok, _student_mark_nilam} = Affairs.delete_student_mark_nilam(student_mark_nilam)

    conn
    |> put_flash(:info, "Student mark nilam deleted successfully.")
    |> redirect(to: student_mark_nilam_path(conn, :index))
  end
end
