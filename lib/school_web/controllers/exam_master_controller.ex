defmodule SchoolWeb.ExamMasterController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ExamMaster
  require IEx

  def index(conn, _params) do
    exam_master = Affairs.list_exam_master()
    render(conn, "index.html", exam_master: exam_master)
  end

  def new(conn, _params) do
    changeset = Affairs.change_exam_master(%ExamMaster{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"exam_master" => exam_master_params}) do
    case Affairs.create_exam_master(exam_master_params) do
      {:ok, exam_master} ->
        conn
        |> put_flash(:info, "Exam master created successfully.")
        |> redirect(to: exam_master_path(conn, :show, exam_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    exam_master = Affairs.get_exam_master!(id)
    render(conn, "show.html", exam_master: exam_master)
  end

  def edit(conn, %{"id" => id}) do
    exam_master = Affairs.get_exam_master!(id)
    changeset = Affairs.change_exam_master(exam_master)
    render(conn, "edit.html", exam_master: exam_master, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exam_master" => exam_master_params}) do
    exam_master = Affairs.get_exam_master!(id)

    case Affairs.update_exam_master(exam_master, exam_master_params) do
      {:ok, exam_master} ->
        conn
        |> put_flash(:info, "Exam master updated successfully.")
        |> redirect(to: exam_master_path(conn, :show, exam_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", exam_master: exam_master, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exam_master = Affairs.get_exam_master!(id)
    {:ok, _exam_master} = Affairs.delete_exam_master(exam_master)

    conn
    |> put_flash(:info, "Exam master deleted successfully.")
    |> redirect(to: exam_master_path(conn, :index))
  end
end
