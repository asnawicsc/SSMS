defmodule SchoolWeb.CoCurriculumJobController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.CoCurriculumJob

  def index(conn, _params) do
    cocurriculum_job = Affairs.list_cocurriculum_job()
    render(conn, "index.html", cocurriculum_job: cocurriculum_job)
  end

  def new(conn, _params) do
    changeset = Affairs.change_co_curriculum_job(%CoCurriculumJob{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"co_curriculum_job" => co_curriculum_job_params}) do
    case Affairs.create_co_curriculum_job(co_curriculum_job_params) do
      {:ok, co_curriculum_job} ->
        conn
        |> put_flash(:info, "Co curriculum job created successfully.")
           |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    co_curriculum_job = Affairs.get_co_curriculum_job!(id)
    render(conn, "show.html", co_curriculum_job: co_curriculum_job)
  end

  def edit(conn, %{"id" => id}) do
    co_curriculum_job = Affairs.get_co_curriculum_job!(id)
    changeset = Affairs.change_co_curriculum_job(co_curriculum_job)
    render(conn, "edit.html", co_curriculum_job: co_curriculum_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "co_curriculum_job" => co_curriculum_job_params}) do
    co_curriculum_job = Affairs.get_co_curriculum_job!(id)

    case Affairs.update_co_curriculum_job(co_curriculum_job, co_curriculum_job_params) do
      {:ok, co_curriculum_job} ->
        conn
        |> put_flash(:info, "Co curriculum job updated successfully.")
          |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", co_curriculum_job: co_curriculum_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    co_curriculum_job = Affairs.get_co_curriculum_job!(id)
    {:ok, _co_curriculum_job} = Affairs.delete_co_curriculum_job(co_curriculum_job)

    conn
    |> put_flash(:info, "Co curriculum job deleted successfully.")
       |> redirect(to: teacher_path(conn, :teacher_setting))
  end
end
