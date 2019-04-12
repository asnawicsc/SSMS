defmodule SchoolWeb.ExamAttendanceController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ExamAttendance

  def index(conn, _params) do
    exam_attendance = Affairs.list_exam_attendance()
    render(conn, "index.html", exam_attendance: exam_attendance)
  end

  def new(conn, _params) do
    changeset = Affairs.change_exam_attendance(%ExamAttendance{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"exam_attendance" => exam_attendance_params}) do
    case Affairs.create_exam_attendance(exam_attendance_params) do
      {:ok, exam_attendance} ->
        conn
        |> put_flash(:info, "Exam attendance created successfully.")
        |> redirect(to: exam_attendance_path(conn, :show, exam_attendance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    exam_attendance = Affairs.get_exam_attendance!(id)
    render(conn, "show.html", exam_attendance: exam_attendance)
  end

  def edit(conn, %{"id" => id}) do
    exam_attendance = Affairs.get_exam_attendance!(id)
    changeset = Affairs.change_exam_attendance(exam_attendance)
    render(conn, "edit.html", exam_attendance: exam_attendance, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exam_attendance" => exam_attendance_params}) do
    exam_attendance = Affairs.get_exam_attendance!(id)

    case Affairs.update_exam_attendance(exam_attendance, exam_attendance_params) do
      {:ok, exam_attendance} ->
        conn
        |> put_flash(:info, "Exam attendance updated successfully.")
        |> redirect(to: exam_attendance_path(conn, :show, exam_attendance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", exam_attendance: exam_attendance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exam_attendance = Affairs.get_exam_attendance!(id)
    {:ok, _exam_attendance} = Affairs.delete_exam_attendance(exam_attendance)

    conn
    |> put_flash(:info, "Exam attendance deleted successfully.")
    |> redirect(to: exam_attendance_path(conn, :index))
  end
end
