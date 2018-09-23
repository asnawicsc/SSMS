defmodule SchoolWeb.TeacherCoCurriculumJobController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TeacherCoCurriculumJob

  def index(conn, _params) do
    teacher_co_curriculum_job = Affairs.list_teacher_co_curriculum_job()|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    render(conn, "index.html", teacher_co_curriculum_job: teacher_co_curriculum_job)
  end

  def new(conn, _params) do

      semester =
      Repo.all(from(s in School.Affairs.Semester, select: %{institution_id: s.institution_id,id: s.id, start_date: s.start_date}))|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)

      teacher=Repo.all(School.Affairs.Teacher)|>Enum.filter(fn x -> x.name !="Rehat" end)|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
       co_curriculum=Repo.all(School.Affairs.CoCurriculumJob)|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    changeset = Affairs.change_teacher_co_curriculum_job(%TeacherCoCurriculumJob{})
    render(conn, "new.html", changeset: changeset,semester: semester,teacher: teacher,co_curriculum: co_curriculum)
  end

    def create_teacher_cocurriculum_job(conn, params) do

      teacher_co_curriculum_job_params=%{semester_id: params["semester"], teacher_id: params["teacher"],co_curriculum_job_id: params["co_curriculum"],institution_id: conn.private.plug_session["institution_id"]}
    case Affairs.create_teacher_co_curriculum_job(teacher_co_curriculum_job_params) do
      {:ok, teacher_co_curriculum_job} ->
        conn
        |> put_flash(:info, "Teacher co curriculum job created successfully.")
           |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"teacher_co_curriculum_job" => teacher_co_curriculum_job_params}) do
    case Affairs.create_teacher_co_curriculum_job(teacher_co_curriculum_job_params) do
      {:ok, teacher_co_curriculum_job} ->
        conn
        |> put_flash(:info, "Teacher co curriculum job created successfully.")
        |> redirect(to: teacher_co_curriculum_job_path(conn, :show, teacher_co_curriculum_job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher_co_curriculum_job = Affairs.get_teacher_co_curriculum_job!(id)
    render(conn, "show.html", teacher_co_curriculum_job: teacher_co_curriculum_job)
  end

  def edit(conn, %{"id" => id}) do
    teacher_co_curriculum_job = Affairs.get_teacher_co_curriculum_job!(id)
    changeset = Affairs.change_teacher_co_curriculum_job(teacher_co_curriculum_job)
    render(conn, "edit.html", teacher_co_curriculum_job: teacher_co_curriculum_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher_co_curriculum_job" => teacher_co_curriculum_job_params}) do
    teacher_co_curriculum_job = Affairs.get_teacher_co_curriculum_job!(id)

    case Affairs.update_teacher_co_curriculum_job(teacher_co_curriculum_job, teacher_co_curriculum_job_params) do
      {:ok, teacher_co_curriculum_job} ->
        conn
        |> put_flash(:info, "Teacher co curriculum job updated successfully.")
        |> redirect(to: teacher_co_curriculum_job_path(conn, :show, teacher_co_curriculum_job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_co_curriculum_job: teacher_co_curriculum_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_co_curriculum_job = Affairs.get_teacher_co_curriculum_job!(id)
    {:ok, _teacher_co_curriculum_job} = Affairs.delete_teacher_co_curriculum_job(teacher_co_curriculum_job)

    conn
    |> put_flash(:info, "Teacher co curriculum job deleted successfully.")
    |> redirect(to: teacher_co_curriculum_job_path(conn, :index))
  end
end
