defmodule SchoolWeb.ExamMarkController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ExamMark

  def index(conn, _params) do
    exam_mark = Affairs.list_exam_mark()
    render(conn, "index.html", exam_mark: exam_mark)
  end

  def new(conn, _params) do
    changeset = Affairs.change_exam_mark(%ExamMark{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"exam_mark" => exam_mark_params}) do
    case Affairs.create_exam_mark(exam_mark_params) do
      {:ok, exam_mark} ->
        conn
        |> put_flash(:info, "Exam mark created successfully.")
        |> redirect(to: exam_mark_path(conn, :show, exam_mark))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    exam_mark = Affairs.get_exam_mark!(id)
    render(conn, "show.html", exam_mark: exam_mark)
  end

  def edit(conn, %{"id" => id}) do
    exam_mark = Affairs.get_exam_mark!(id)
    changeset = Affairs.change_exam_mark(exam_mark)
    render(conn, "edit.html", exam_mark: exam_mark, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exam_mark" => exam_mark_params}) do
    exam_mark = Affairs.get_exam_mark!(id)

    case Affairs.update_exam_mark(exam_mark, exam_mark_params) do
      {:ok, exam_mark} ->
        conn
        |> put_flash(:info, "Exam mark updated successfully.")
        |> redirect(to: exam_mark_path(conn, :show, exam_mark))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", exam_mark: exam_mark, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exam_mark = Affairs.get_exam_mark!(id)
    {:ok, _exam_mark} = Affairs.delete_exam_mark(exam_mark)

    conn
    |> put_flash(:info, "Exam mark deleted successfully.")
    |> redirect(to: exam_mark_path(conn, :index))
  end
end
