defmodule SchoolWeb.CoCurriculumController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.CoCurriculum
require IEx
  def index(conn, _params) do
    cocurriculum = Affairs.list_cocurriculum()
    render(conn, "index.html", cocurriculum: cocurriculum)
  end

  def new(conn, _params) do
    changeset = Affairs.change_co_curriculum(%CoCurriculum{})
    render(conn, "new.html", changeset: changeset)
  end

  def student_report_by_cocurriculum(conn,params) do

     cocurriculum = Affairs.list_cocurriculum()
      render(conn, "student_report_by_cocurriculum.html",cocurriculum: cocurriculum)
  end

  def create_student_co(conn,params) do

    cocurriculum_id = params["cocurriculum"]
    standard_id = params["level"]
    subjects = params["student"] |> String.split(",")
    semester_id=params["semester"]
    year=params["year"]

 
        for subject <- subjects do
          subject_id = subject|>String.to_integer

           params = %{
              cocurriculum_id: cocurriculum_id,
              standard_id: standard_id,
              student_id: subject_id,
              semester_id: semester_id,
              year: year
            }

          Affairs.create_student_cocurriculum(params)
        end

        conn
        |> put_flash(:info, "Student cocurriculum created successfully.")
        |> redirect(to: co_curriculum_path(conn, :co_curriculum_setting))

  end

  def create_co_mark(conn,params) do
   marks=params["mark"]

 

        for mark <- marks do

          student_id=mark|>elem(0)
          co_mark=mark|>elem(1)
           
    semester_id=params["semester_id"]
    standard_id=params["standard_id"]
    year=params["year"]
   cocurriculum_id=params["cocurriculum_id"]

          id=Repo.get_by(School.Affairs.StudentCocurriculum,%{cocurriculum_id: cocurriculum_id,student_id: student_id})
         


           params = %{
              cocurriculum_id: cocurriculum_id,
              standard_id: standard_id,
              student_id: student_id,
              semester_id: semester_id,
              year: year,
              mark: co_mark
            }

          Affairs.update_student_cocurriculum(id,params)
        end

        conn
        |> put_flash(:info, "Student cocurriculum mark created successfully.")
        |> redirect(to: co_curriculum_path(conn, :co_curriculum_setting))



  end

    def edit_co_mark(conn,params) do

   marks=params["mark"]

 

        for mark <- marks do

          student_id=mark|>elem(0)
          co_mark=mark|>elem(1)
           
    semester_id=params["semester_id"]
    standard_id=params["standard_id"]
    year=params["year"]
   cocurriculum_id=params["cocurriculum_id"]

          id=Repo.get_by(School.Affairs.StudentCocurriculum,%{cocurriculum_id: cocurriculum_id,student_id: student_id})
         


           params = %{
              cocurriculum_id: cocurriculum_id,
              standard_id: standard_id,
              student_id: student_id,
              semester_id: semester_id,
              year: year,
              mark: co_mark
            }

          Affairs.update_student_cocurriculum(id,params)
        end

        conn
        |> put_flash(:info, "Student cocurriculum mark updated successfully.")
        |> redirect(to: co_curriculum_path(conn, :co_curriculum_setting))



  end

    def co_mark(conn,params) do
 cocurriculum = Affairs.list_cocurriculum()
 render(conn, "co_mark.html",cocurriculum: cocurriculum)

  end

    def co_curriculum_setting(conn, _params) do
          level = Repo.all(from(s in School.Affairs.Level, select: %{id: s.id, name: s.name}))

              semester =
      Repo.all(from(s in School.Affairs.Semester, select: %{id: s.id, start_date: s.start_date}))

          students=Repo.all(from s in School.Affairs.StudentClass,
            left_join: a in School.Affairs.Student, on: s.sudent_id==a.id,
            left_join: c in School.Affairs.Class, on: s.class_id==c.id,
            left_join: m in School.Affairs.StudentCocurriculum, on: s.sudent_id !=m.id,
        select: %{id: a.id, name: a.name,class_name: c.name})|>Enum.uniq

          cocurriculum = Affairs.list_cocurriculum()
    changeset = Affairs.change_co_curriculum(%CoCurriculum{})
    render(conn, "co_curriculum_setting.html",semester: semester,students: students,level: level,cocurriculum: cocurriculum, changeset: changeset)
  end

  def create(conn, %{"co_curriculum" => co_curriculum_params}) do
    case Affairs.create_co_curriculum(co_curriculum_params) do
      {:ok, co_curriculum} ->
        conn
        |> put_flash(:info, "Co curriculum created successfully.")
        |> redirect(to: co_curriculum_path(conn, :co_curriculum_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    co_curriculum = Affairs.get_co_curriculum!(id)
    render(conn, "show.html", co_curriculum: co_curriculum)
  end

  def edit(conn, %{"id" => id}) do
    co_curriculum = Affairs.get_co_curriculum!(id)
    changeset = Affairs.change_co_curriculum(co_curriculum)
    render(conn, "edit.html", co_curriculum: co_curriculum, changeset: changeset)
  end

  def update(conn, %{"id" => id, "co_curriculum" => co_curriculum_params}) do
    co_curriculum = Affairs.get_co_curriculum!(id)

    case Affairs.update_co_curriculum(co_curriculum, co_curriculum_params) do
      {:ok, co_curriculum} ->
        conn
        |> put_flash(:info, "Co curriculum updated successfully.")
        |> redirect(to: co_curriculum_path(conn, :show, co_curriculum))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", co_curriculum: co_curriculum, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    co_curriculum = Affairs.get_co_curriculum!(id)
    {:ok, _co_curriculum} = Affairs.delete_co_curriculum(co_curriculum)

    conn
    |> put_flash(:info, "Co curriculum deleted successfully.")
    |> redirect(to: co_curriculum_path(conn, :index))
  end
end
