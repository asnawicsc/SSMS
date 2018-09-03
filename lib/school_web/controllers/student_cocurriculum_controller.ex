defmodule SchoolWeb.StudentCocurriculumController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.StudentCocurriculum

  def index(conn, _params) do
    student_cocurriculum = Affairs.list_student_cocurriculum()
    render(conn, "index.html", student_cocurriculum: student_cocurriculum)
  end

  def new(conn, _params) do
    changeset = Affairs.change_student_cocurriculum(%StudentCocurriculum{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"student_cocurriculum" => student_cocurriculum_params}) do
    case Affairs.create_student_cocurriculum(student_cocurriculum_params) do
      {:ok, student_cocurriculum} ->
        conn
        |> put_flash(:info, "Student cocurriculum created successfully.")
        |> redirect(to: student_cocurriculum_path(conn, :show, student_cocurriculum))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    student_cocurriculum = Affairs.get_student_cocurriculum!(id)
    render(conn, "show.html", student_cocurriculum: student_cocurriculum)
  end

  def edit(conn, %{"id" => id}) do
    student_cocurriculum = Affairs.get_student_cocurriculum!(id)
    changeset = Affairs.change_student_cocurriculum(student_cocurriculum)
    render(conn, "edit.html", student_cocurriculum: student_cocurriculum, changeset: changeset)
  end

  def update(conn, %{"id" => id, "student_cocurriculum" => student_cocurriculum_params}) do
    student_cocurriculum = Affairs.get_student_cocurriculum!(id)

    case Affairs.update_student_cocurriculum(student_cocurriculum, student_cocurriculum_params) do
      {:ok, student_cocurriculum} ->
        conn
        |> put_flash(:info, "Student cocurriculum updated successfully.")
        |> redirect(to: student_cocurriculum_path(conn, :show, student_cocurriculum))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", student_cocurriculum: student_cocurriculum, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    student_cocurriculum = Affairs.get_student_cocurriculum!(id)
    {:ok, _student_cocurriculum} = Affairs.delete_student_cocurriculum(student_cocurriculum)

    conn
    |> put_flash(:info, "Student cocurriculum deleted successfully.")
    |> redirect(to: student_cocurriculum_path(conn, :index))
  end
end
