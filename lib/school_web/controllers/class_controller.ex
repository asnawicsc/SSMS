defmodule SchoolWeb.ClassController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Class
  require IEx
  def add_to_class_semester(conn, %{"institute_id" => institute_id, "semester_id" => semester_id, "student_id" => student_id, "class_id" => class_id}) do

    class = Repo.get(Class, class_id)
    student = Repo.get(School.Affairs.Student, student_id)
    sc = Repo.get_by(School.Affairs.StudentClass, class_id: class_id, sudent_id: student_id, semester_id: semester_id, institute_id: institute_id)
    if  sc == nil do
      School.Affairs.StudentClass.changeset(%School.Affairs.StudentClass{}, %{class_id: class_id, sudent_id: student_id, semester_id: semester_id, institute_id: institute_id, level_id: class.level_id}) |> Repo.insert()
      action = "has been added to"
      type = "success"
    else
      Repo.delete(sc)
      action =  "has been removed from"
      type = "danger"
    end

    map = %{student: student.name, class: class.name, action: action, type: type} |> Poison.encode!


     send_resp(conn, 200, map)
  end

  def students(conn, params) do
    students = Repo.all(from s in School.Affairs.Student, where: s.institution_id == ^School.Affairs.inst_id(conn), select: %{name: s.name, id: s.id} )
    # list of all students

    # list of all students in this class, in this semester using student class

    students_in = Repo.all(from s in School.Affairs.StudentClass, left_join: t in School.Affairs.Student, on: t.id == s.sudent_id, where: 
      s.institute_id == ^School.Affairs.inst_id(conn) and 
      s.semester_id == ^conn.private.plug_session["semester_id"] and
      s.class_id == ^String.to_integer(params["id"]), select: %{name: t.name, id: t.id})

    students_in_out = Repo.all(from s in School.Affairs.StudentClass, left_join: t in School.Affairs.Student, on: t.id == s.sudent_id, where: 
      s.institute_id == ^School.Affairs.inst_id(conn) and 
      s.semester_id == ^conn.private.plug_session["semester_id"] , select: %{name: t.name, id: t.id})


    rem = students -- students_in_out
    class = Repo.get(Class, params["id"])
    render(conn, "students.html", students: rem, class: class, students_in: students_in)
  end
  def index(conn, _params) do
    classes = Affairs.list_classes(conn.private.plug_session["institution_id"])
    render(conn, "index.html", classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_class(%Class{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"class" => class_params}) do
    class_params = Map.put(class_params, "institution_id", conn.private.plug_session["institution_id"])
    case Affairs.create_class(class_params) do
      {:ok, class} ->
        conn
        |> put_flash(:info, "Class created successfully.")
        |> redirect(to: class_path(conn, :show, class))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)
    render(conn, "show.html", class: class)
  end

  def edit(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)
    changeset = Affairs.change_class(class)
    render(conn, "edit.html", class: class, changeset: changeset)
  end

  def update(conn, %{"id" => id, "class" => class_params}) do
    class = Affairs.get_class!(id)
    class_params = Map.put(class_params, "institution_id", conn.private.plug_session["institution_id"])
    case Affairs.update_class(class, class_params) do
      {:ok, class} ->
        conn
        |> put_flash(:info, "Class updated successfully.")
        |> redirect(to: class_path(conn, :show, class))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", class: class, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)
    {:ok, _class} = Affairs.delete_class(class)

    conn
    |> put_flash(:info, "Class deleted successfully.")
    |> redirect(to: class_path(conn, :index))
  end
end
