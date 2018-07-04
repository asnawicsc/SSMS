defmodule SchoolWeb.ClassController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Class

  def add_to_class_semester(conn, params) do

     send_resp(conn, 200, "ok")
  end

  def students(conn, params) do
    students = Repo.all(from s in School.Affairs.Student, where: s.institution_id == ^School.Affairs.inst_id(conn) )
    # list of all students

    # list of all students in this class, in this semester using student class

    students_in = Repo.all(from s in School.Affairs.StudentClass, where: s.institute_id == ^School.Affairs.inst_id(conn) and s.class_id == ^String.to_integer(params["id"]))
    class = Repo.get(Class, params["id"])
    render(conn, "students.html", students: students, class: class)
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
