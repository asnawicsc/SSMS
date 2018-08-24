defmodule SchoolWeb.SchoolJobController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.SchoolJob

  def index(conn, _params) do
    school_job = Affairs.list_school_job()
    render(conn, "index.html", school_job: school_job)
  end

  def new(conn, _params) do
    changeset = Affairs.change_school_job(%SchoolJob{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"school_job" => school_job_params}) do
     teacher = Affairs.list_teacher()
    school_job = Affairs.list_school_job()
    co_curriculum_job = Affairs.list_cocurriculum_job()
    hem_job = Affairs.list_hem_job()
    absent_reason = Affairs.list_absent_reason()
    case Affairs.create_school_job(school_job_params) do
      {:ok, school_job} ->
        conn
        |> put_flash(:info, "School job created successfully.")
        |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    school_job = Affairs.get_school_job!(id)
    render(conn, "show.html", school_job: school_job)
  end

  def edit(conn, %{"id" => id}) do
    school_job = Affairs.get_school_job!(id)
    changeset = Affairs.change_school_job(school_job)
    render(conn, "edit.html", school_job: school_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "school_job" => school_job_params}) do
    school_job = Affairs.get_school_job!(id)

    case Affairs.update_school_job(school_job, school_job_params) do
      {:ok, school_job} ->
        conn
        |> put_flash(:info, "School job updated successfully.")
       |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", school_job: school_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    school_job = Affairs.get_school_job!(id)
    {:ok, _school_job} = Affairs.delete_school_job(school_job)

    conn
    |> put_flash(:info, "School job deleted successfully.")
    |> redirect(to: teacher_path(conn, :teacher_setting))
  end
end
