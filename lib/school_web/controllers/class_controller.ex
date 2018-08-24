defmodule SchoolWeb.ClassController do
  use SchoolWeb, :controller
  use Task
  alias School.Affairs
  alias School.Settings.Institution
  alias School.Affairs.{Level, Class}
  require IEx

  def sync_library_membership(conn, params) do
    students_in =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: t in School.Affairs.Student,
          on: t.id == s.sudent_id,
          where:
            s.institute_id == ^School.Affairs.inst_id(conn) and
              s.semester_id == ^conn.private.plug_session["semester_id"] and
              s.class_id == ^String.to_integer(params["id"]),
          select: %{
            chinese_name: t.chinese_name,
            name: t.name,
            id: t.id,
            ic: t.ic,
            student_no: t.student_no,
            phone: t.phone
          }
        )
      )

    inst = Repo.get(Institution, School.Affairs.inst_id(conn))

    uri = "https://www.li6rary.net/api"

    lib_id = inst.library_organization_id

    a =
      for student <- students_in do
        Task.start_link(__MODULE__, :reg_lib_student, [student, lib_id, uri])
      end

    conn
    |> put_flash(:info, "Library membership synced!")
    |> redirect(to: class_path(conn, :index))
  end

  def reg_lib_student(student, lib_id, uri) do
    name = String.replace(student.name, " ", "+")

    path =
      "?scope=get_user_register_response&lib_id=#{lib_id}&name=#{name}&ic=#{student.ic}&phone=#{
        student.phone
      }&code=#{student.student_no}"

    IO.inspect(uri <> path)
    response = HTTPoison.get!(uri <> path, [{"Content-Type", "application/json"}]).body
  end

  def add_to_class_semester(conn, %{
        "institute_id" => institute_id,
        "semester_id" => semester_id,
        "student_id" => student_id,
        "class_id" => class_id
      }) do
    class = Repo.get(Class, class_id)
    student = Repo.get(School.Affairs.Student, student_id)

    sc =
      Repo.get_by(
        School.Affairs.StudentClass,
        class_id: class_id,
        sudent_id: student_id,
        semester_id: semester_id,
        institute_id: institute_id
      )

    {action, type} =
      if sc == nil do
        School.Affairs.StudentClass.changeset(%School.Affairs.StudentClass{}, %{
          class_id: class_id,
          sudent_id: student_id,
          semester_id: semester_id,
          institute_id: institute_id,
          level_id: class.level_id
        })
        |> Repo.insert()

        {"has been added to", "success"}
      else
        Repo.delete(sc)

        {"has been removed from", "danger"}
      end

    map =
      %{student: student.name, class: class.name, action: action, type: type} |> Poison.encode!()

    send_resp(conn, 200, map)
  end

  def students(conn, params) do
    students =
      Repo.all(
        from(
          s in School.Affairs.Student,
          where: s.institution_id == ^School.Affairs.inst_id(conn),
          select: %{chinese_name: s.chinese_name, name: s.name, id: s.id},
          order_by: [s.name]
        )
      )

    # list of all students

    # list of all students in this class, in this semester using student class

    if conn.private.plug_session["semester_id"] == nil do
      current_sem =
        Repo.all(
          from(
            s in School.Affairs.Semester,
            where: s.end_date > ^Timex.today() and s.start_date < ^Timex.today()
          )
        )

      if current_sem == [] do
        conn
        |> put_flash(:info, "Please set the semester info.")
        |> redirect(to: semester_path(conn, :new))
      else
        current_sem = hd(current_sem)

        conn
        |> put_session(:semester_id, current_sem.id)
        |> redirect(to: class_path(conn, :students, params["id"]))
      end
    else
      students_in =
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: t in School.Affairs.Student,
            on: t.id == s.sudent_id,
            where:
              s.institute_id == ^School.Affairs.inst_id(conn) and
                s.semester_id == ^conn.private.plug_session["semester_id"] and
                s.class_id == ^String.to_integer(params["id"]),
            select: %{chinese_name: t.chinese_name, name: t.name, id: t.id}
          )
        )

      students_unassigned =
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: t in School.Affairs.Student,
            on: t.id == s.sudent_id,
            where:
              s.institute_id == ^School.Affairs.inst_id(conn) and
                s.semester_id == ^conn.private.plug_session["semester_id"],
            select: %{chinese_name: t.chinese_name, name: t.name, id: t.id}
          )
        )

      rem = students -- students_unassigned
      class = Repo.get(Class, params["id"])

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.StudentView,
          "index.html",
          students: students_in,
          conn: conn
        )

      render(
        conn,
        "students.html",
        students: rem,
        class: class,
        students_in: students_in,
        html: html
      )
    end
  end

  def index(conn, _params) do
    if conn.private.plug_session["institution_id"] == nil do
      conn
      |> put_flash(:info, "Please select a class.")
      |> redirect(to: institution_path(conn, :index))
    else
      classes = Affairs.list_classes(conn.private.plug_session["institution_id"])
      render(conn, "index.html", classes: classes)
    end
 
  end

  def new(conn, _params) do
    s1 = Repo.get_by(Level, name: "Standard 1")
    if s1 == nil, do: Level.changeset(%Level{}, %{name: "Standard 1"}) |> Repo.insert()
    s2 = Repo.get_by(Level, name: "Standard 2")
    if s2 == nil, do: Level.changeset(%Level{}, %{name: "Standard 2"}) |> Repo.insert()
    s3 = Repo.get_by(Level, name: "Standard 3")
    if s3 == nil, do: Level.changeset(%Level{}, %{name: "Standard 3"}) |> Repo.insert()
    s4 = Repo.get_by(Level, name: "Standard 4")
    if s4 == nil, do: Level.changeset(%Level{}, %{name: "Standard 4"}) |> Repo.insert()
    s5 = Repo.get_by(Level, name: "Standard 5")
    if s5 == nil, do: Level.changeset(%Level{}, %{name: "Standard 5"}) |> Repo.insert()
    s6 = Repo.get_by(Level, name: "Standard 6")
    if s6 == nil, do: Level.changeset(%Level{}, %{name: "Standard 6"}) |> Repo.insert()

    changeset = Affairs.change_class(%Class{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"class" => class_params}) do
    class_params =
      Map.put(class_params, "institution_id", conn.private.plug_session["institution_id"])

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

    class_params =
      Map.put(class_params, "institution_id", conn.private.plug_session["institution_id"])

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
