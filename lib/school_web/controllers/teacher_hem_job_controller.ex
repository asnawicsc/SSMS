defmodule SchoolWeb.TeacherHemJobController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TeacherHemJob
  require IEx

  def index(conn, _params) do
    teacher_hem_job = Affairs.list_teacher_hem_job()|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    render(conn, "index.html", teacher_hem_job: teacher_hem_job)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher_hem_job(%TeacherHemJob{})
          semester =
      Repo.all(from(s in School.Affairs.Semester, select: %{institution_id: s.institution_id,id: s.id, start_date: s.start_date}))|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)

      teacher=Repo.all(School.Affairs.Teacher)|>Enum.filter(fn x -> x.name !="Rehat" end)|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
       hem=Repo.all(School.Affairs.HemJob)|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    render(conn, "new.html", changeset: changeset,semester: semester,teacher: teacher,hem: hem)
  end

     def create_teacher_hem_job(conn, params) do

      teacher_hem_job_params=%{semester_id: params["semester"], teacher_id: params["teacher"],hem_job_id: params["hem"],institution_id: conn.private.plug_session["institution_id"]}
    case Affairs.create_teacher_hem_job(teacher_hem_job_params) do
      {:ok, teacher_hem_job} ->
        conn
        |> put_flash(:info, "Teacher co curriculum job created successfully.")
           |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"teacher_hem_job" => teacher_hem_job_params}) do
    case Affairs.create_teacher_hem_job(teacher_hem_job_params) do
      {:ok, teacher_hem_job} ->
        conn
        |> put_flash(:info, "Teacher hem job created successfully.")
        |> redirect(to: teacher_hem_job_path(conn, :show, teacher_hem_job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher_hem_job = Affairs.get_teacher_hem_job!(id)
    render(conn, "show.html", teacher_hem_job: teacher_hem_job)
  end

  def edit(conn, %{"id" => id}) do
    teacher_hem_job = Affairs.get_teacher_hem_job!(id)
    changeset = Affairs.change_teacher_hem_job(teacher_hem_job)
    render(conn, "edit.html", teacher_hem_job: teacher_hem_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher_hem_job" => teacher_hem_job_params}) do
    teacher_hem_job = Affairs.get_teacher_hem_job!(id)

    case Affairs.update_teacher_hem_job(teacher_hem_job, teacher_hem_job_params) do
      {:ok, teacher_hem_job} ->
        conn
        |> put_flash(:info, "Teacher hem job updated successfully.")
        |> redirect(to: teacher_hem_job_path(conn, :show, teacher_hem_job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_hem_job: teacher_hem_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_hem_job = Affairs.get_teacher_hem_job!(id)
    {:ok, _teacher_hem_job} = Affairs.delete_teacher_hem_job(teacher_hem_job)

    conn
    |> put_flash(:info, "Teacher hem job deleted successfully.")
    |> redirect(to: teacher_hem_job_path(conn, :index))
  end
end
