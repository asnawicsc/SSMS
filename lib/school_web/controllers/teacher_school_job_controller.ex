defmodule SchoolWeb.TeacherSchoolJobController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.TeacherSchoolJob
    alias School.Affairs.Teacher
     alias School.Affairs.Semester

  def index(conn, _params) do
    teacher_school_job = Affairs.list_teacher_school_job()|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    render(conn, "index.html", teacher_school_job: teacher_school_job)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher_school_job(%TeacherSchoolJob{})

      semester =
      Repo.all(from(s in School.Affairs.Semester, select: %{institution_id: s.institution_id,id: s.id, start_date: s.start_date}))|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)

      teacher=Repo.all(School.Affairs.Teacher)|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)|>Enum.filter(fn x -> x.name !="Rehat" end)
       school_job=Repo.all(School.Affairs.SchoolJob)|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    render(conn, "new.html", changeset: changeset,semester: semester,teacher: teacher,school_job: school_job)
  end

    def create_teacher_school_job(conn, params) do
teacher_school_job_params=%{semester_id: params["semester"], teacher_id: params["teacher"],school_job_id: params["school_job"],institution_id: conn.private.plug_session["institution_id"]}

    case Affairs.create_teacher_school_job(teacher_school_job_params) do
      {:ok, teacher_school_job} ->
        conn
        |> put_flash(:info, "Teacher school job created successfully.")
        |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"teacher_school_job" => teacher_school_job_params}) do
    case Affairs.create_teacher_school_job(teacher_school_job_params) do
      {:ok, teacher_school_job} ->
        conn
        |> put_flash(:info, "Teacher school job created successfully.")
        |> redirect(to: teacher_school_job_path(conn, :show, teacher_school_job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher_school_job = Affairs.get_teacher_school_job!(id)
    render(conn, "show.html", teacher_school_job: teacher_school_job)
  end

  def edit(conn, %{"id" => id}) do
    teacher_school_job = Affairs.get_teacher_school_job!(id)
    changeset = Affairs.change_teacher_school_job(teacher_school_job)
    render(conn, "edit.html", teacher_school_job: teacher_school_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher_school_job" => teacher_school_job_params}) do
    teacher_school_job = Affairs.get_teacher_school_job!(id)

    case Affairs.update_teacher_school_job(teacher_school_job, teacher_school_job_params) do
      {:ok, teacher_school_job} ->
        conn
        |> put_flash(:info, "Teacher school job updated successfully.")
        |> redirect(to: teacher_school_job_path(conn, :show, teacher_school_job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_school_job: teacher_school_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_school_job = Affairs.get_teacher_school_job!(id)
    {:ok, _teacher_school_job} = Affairs.delete_teacher_school_job(teacher_school_job)

    conn
    |> put_flash(:info, "Teacher school job deleted successfully.")
    |> redirect(to: teacher_school_job_path(conn, :index))
  end
end
