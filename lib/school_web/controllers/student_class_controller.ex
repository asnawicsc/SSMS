defmodule SchoolWeb.StudentClassController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.StudentClass

  def index(conn, _params) do
    student_classes = Affairs.list_student_classes()
    render(conn, "index.html", student_classes: student_classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_student_class(%StudentClass{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"student_class" => student_class_params}) do
    case Affairs.create_student_class(student_class_params) do
      {:ok, student_class} ->
        conn
        |> put_flash(:info, "Student class created successfully.")
        |> redirect(to: student_class_path(conn, :show, student_class))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    student_class = Affairs.get_student_class!(id)
    render(conn, "show.html", student_class: student_class)
  end

  def edit(conn, %{"id" => id}) do
    student_class = Affairs.get_student_class!(id)
    changeset = Affairs.change_student_class(student_class)
    render(conn, "edit.html", student_class: student_class, changeset: changeset)
  end

  def update(conn, %{"id" => id, "student_class" => student_class_params}) do
    student_class = Affairs.get_student_class!(id)

    case Affairs.update_student_class(student_class, student_class_params) do
      {:ok, student_class} ->
        conn
        |> put_flash(:info, "Student class updated successfully.")
        |> redirect(to: student_class_path(conn, :show, student_class))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", student_class: student_class, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    student_class = Affairs.get_student_class!(id)
    {:ok, _student_class} = Affairs.delete_student_class(student_class)

    conn
    |> put_flash(:info, "Student class deleted successfully.")
    |> redirect(to: student_class_path(conn, :index))
  end
end
