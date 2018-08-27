defmodule SchoolWeb.TeacherAbsentReasonController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TeacherAbsentReason

  def index(conn, _params) do
    teacher_absent_reason = Affairs.list_teacher_absent_reason()
    render(conn, "index.html", teacher_absent_reason: teacher_absent_reason)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher_absent_reason(%TeacherAbsentReason{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teacher_absent_reason" => teacher_absent_reason_params}) do
    case Affairs.create_teacher_absent_reason(teacher_absent_reason_params) do
      {:ok, teacher_absent_reason} ->
        conn
        |> put_flash(:info, "Teacher absent reason created successfully.")
        |> redirect(to: teacher_absent_reason_path(conn, :show, teacher_absent_reason))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher_absent_reason = Affairs.get_teacher_absent_reason!(id)
    render(conn, "show.html", teacher_absent_reason: teacher_absent_reason)
  end

  def edit(conn, %{"id" => id}) do
    teacher_absent_reason = Affairs.get_teacher_absent_reason!(id)
    changeset = Affairs.change_teacher_absent_reason(teacher_absent_reason)
    render(conn, "edit.html", teacher_absent_reason: teacher_absent_reason, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher_absent_reason" => teacher_absent_reason_params}) do
    teacher_absent_reason = Affairs.get_teacher_absent_reason!(id)

    case Affairs.update_teacher_absent_reason(teacher_absent_reason, teacher_absent_reason_params) do
      {:ok, teacher_absent_reason} ->
        conn
        |> put_flash(:info, "Teacher absent reason updated successfully.")
        |> redirect(to: teacher_absent_reason_path(conn, :show, teacher_absent_reason))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_absent_reason: teacher_absent_reason, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_absent_reason = Affairs.get_teacher_absent_reason!(id)
    {:ok, _teacher_absent_reason} = Affairs.delete_teacher_absent_reason(teacher_absent_reason)

    conn
    |> put_flash(:info, "Teacher absent reason deleted successfully.")
    |> redirect(to: teacher_absent_reason_path(conn, :index))
  end
end
