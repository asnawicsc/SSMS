defmodule SchoolWeb.HemJobController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.HemJob

  def index(conn, _params) do
    hem_job = Affairs.list_hem_job()
    render(conn, "index.html", hem_job: hem_job)
  end

  def new(conn, _params) do
    changeset = Affairs.change_hem_job(%HemJob{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"hem_job" => hem_job_params}) do
    case Affairs.create_hem_job(hem_job_params) do
      {:ok, hem_job} ->
        conn
        |> put_flash(:info, "Hem job created successfully.")
        |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hem_job = Affairs.get_hem_job!(id)
    render(conn, "show.html", hem_job: hem_job)
  end

  def edit(conn, %{"id" => id}) do
    hem_job = Affairs.get_hem_job!(id)
    changeset = Affairs.change_hem_job(hem_job)
    render(conn, "edit.html", hem_job: hem_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "hem_job" => hem_job_params}) do
    hem_job = Affairs.get_hem_job!(id)

    case Affairs.update_hem_job(hem_job, hem_job_params) do
      {:ok, hem_job} ->
        conn
        |> put_flash(:info, "Hem job updated successfully.")
       |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", hem_job: hem_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    hem_job = Affairs.get_hem_job!(id)
    {:ok, _hem_job} = Affairs.delete_hem_job(hem_job)

    conn
    |> put_flash(:info, "Hem job deleted successfully.")
    |> redirect(to: teacher_path(conn, :teacher_setting))
  end
end
