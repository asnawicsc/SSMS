defmodule SchoolWeb.AttendanceController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.{Absent, StudentClass, Class, Attendance, Level, Student}
  require IEx


  def add_to_class_absent(conn, %{
    "absent_reason" => absent_reason, 
    "institute_id" => institute_id, 
    "semester_id" => semester_id, 
    "student_id" => student_id, 
    "class_id" => class_id}) do

    class = Repo.get(Class, class_id)
    student = Repo.get(School.Affairs.Student, student_id)
    Absent.changeset(%Absent{}, %{

      institution_id: institute_id, 
      class_id: class_id, 
      student_id: student_id, 
      semester_id: semester_id, 
      reason: absent_reason, 
      absent_date: Date.utc_today
      }) |> Repo.insert()



    map = %{student: student.name, class: class.name, action: absent_reason, type: "warning"} |> Poison.encode!


     send_resp(conn, 200, map)
  end

  def add_to_class_attendance(conn, %{"institute_id" => institute_id, "semester_id" => semester_id, "student_id" => student_id, "class_id" => class_id}) do

    class = Repo.get(Class, class_id)
    student = Repo.get(School.Affairs.Student, student_id)
    attendance = Repo.get_by(School.Affairs.Attendance, attendance_date: Date.utc_today, class_id: class_id, semester_id: semester_id, institution_id: institute_id)
     student_ids = attendance.student_id |> String.split(",") 

    if Enum.any?(student_ids, fn x -> x == student_id end) do
      student_ids = List.delete(student_ids, student_id) |> Enum.join(",")

      Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!

      action =  "has been marked as absent."
      type = "danger"
    else
      student_ids = List.insert_at(student_ids, 0, student_id) |> Enum.join(",")

      Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!

      abs = Repo.get_by(Absent, absent_date: Date.utc_today, student_id: student_id)
      if abs != nil do
        
        Repo.delete(abs)
      end
      action = "has been marked as attended."
      type = "success"
    end

    map = %{student: student.name, class: class.name, action: action, type: type} |> Poison.encode!


     send_resp(conn, 200, map)
  end

  def mark_attendance(conn, params) do
     class = Repo.get(Class, params["class_id"]) 
     attendance = Repo.get_by(Attendance, attendance_date: Date.utc_today, class_id: class.id, semester_id: conn.private.plug_session["semester_id"])
     if attendance == nil do
      cg = Attendance.changeset(%Attendance{}, %{institution_id: Affairs.inst_id(conn), attendance_date: Date.utc_today, class_id: class.id, semester_id: conn.private.plug_session["semester_id"]})
      {:ok, attendance} = Repo.insert(cg)

     end
     students = Repo.all(from s in Student, left_join: sc in StudentClass, on: sc.sudent_id == s.id, where: sc.institute_id == ^Affairs.inst_id(conn) and sc.semester_id == ^conn.private.plug_session["semester_id"] and sc.class_id == ^class.id)


     student_ids = attendance.student_id |> String.split(",") |> Enum.reject( fn x -> x == "" end)

     if student_ids != [] do
     attended_students = Repo.all(from s in Student, where: s.id in ^student_ids, order_by: [s.name] )
       else
        attended_students = []
     end

     rem = students -- attended_students
     render conn, "mark_attendance.html", class: class, attendance: attendance, students: rem, attended_students: attended_students
  end

  def index(conn, _params) do
    attendance = Affairs.list_attendance()

    classes = Repo.all(from c in Class, left_join: l in Level, on: c.level_id == l.id, where: c.institution_id == ^School.Affairs.inst_id(conn), select: %{id: c.id, level: l.name, class: c.name}, order_by: [c.name]) |> Enum.group_by(fn x -> x.level end)

    render(conn, "index.html", attendance: attendance, classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_attendance(%Attendance{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"attendance" => attendance_params}) do
    case Affairs.create_attendance(attendance_params) do
      {:ok, attendance} ->
        conn
        |> put_flash(:info, "Attendance created successfully.")
        |> redirect(to: attendance_path(conn, :show, attendance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attendance = Affairs.get_attendance!(id)
    render(conn, "show.html", attendance: attendance)
  end

  def edit(conn, %{"id" => id}) do
    attendance = Affairs.get_attendance!(id)
    changeset = Affairs.change_attendance(attendance)
    render(conn, "edit.html", attendance: attendance, changeset: changeset)
  end

  def update(conn, %{"id" => id, "attendance" => attendance_params}) do
    attendance = Affairs.get_attendance!(id)

    case Affairs.update_attendance(attendance, attendance_params) do
      {:ok, attendance} ->
        conn
        |> put_flash(:info, "Attendance updated successfully.")
        |> redirect(to: attendance_path(conn, :show, attendance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", attendance: attendance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    attendance = Affairs.get_attendance!(id)
    {:ok, _attendance} = Affairs.delete_attendance(attendance)

    conn
    |> put_flash(:info, "Attendance deleted successfully.")
    |> redirect(to: attendance_path(conn, :index))
  end
end
