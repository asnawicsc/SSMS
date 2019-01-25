defmodule SchoolWeb.TeacherAttendanceController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TeacherAttendance

  def index(conn, _params) do
    teacher_attendance = Affairs.list_teacher_attendance()
    render(conn, "index.html", teacher_attendance: teacher_attendance)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher_attendance(%TeacherAttendance{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teacher_attendance" => teacher_attendance_params}) do
    case Affairs.create_teacher_attendance(teacher_attendance_params) do
      {:ok, teacher_attendance} ->
        conn
        |> put_flash(:info, "Teacher attendance created successfully.")
        |> redirect(to: teacher_attendance_path(conn, :show, teacher_attendance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)
    render(conn, "show.html", teacher_attendance: teacher_attendance)
  end

  def edit(conn, %{"id" => id}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)
    changeset = Affairs.change_teacher_attendance(teacher_attendance)
    render(conn, "edit.html", teacher_attendance: teacher_attendance, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher_attendance" => teacher_attendance_params}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)

    case Affairs.update_teacher_attendance(teacher_attendance, teacher_attendance_params) do
      {:ok, teacher_attendance} ->
        conn
        |> put_flash(:info, "Teacher attendance updated successfully.")
        |> redirect(to: teacher_attendance_path(conn, :show, teacher_attendance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_attendance: teacher_attendance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)
    {:ok, _teacher_attendance} = Affairs.delete_teacher_attendance(teacher_attendance)

    conn
    |> put_flash(:info, "Teacher attendance deleted successfully.")
    |> redirect(to: teacher_attendance_path(conn, :index))
  end
end
