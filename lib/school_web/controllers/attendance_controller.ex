defmodule SchoolWeb.AttendanceController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.{Absent, Semester, StudentClass, Class, Attendance, Level, Student}
  require IEx

  def add_to_class_absent(conn, %{
        "absent_reason" => absent_reason,
        "institute_id" => institute_id,
        "semester_id" => semester_id,
        "student_id" => student_id,
        "class_id" => class_id
      }) do
    class = Repo.get(Class, class_id)
    student = Repo.get(School.Affairs.Student, student_id)

    abs =
      Repo.all(
        from(
          a in Absent,
          where: a.absent_date == ^Date.utc_today() and a.student_id == ^student_id
        )
      )

    if abs != [] do
      Repo.delete_all(
        from(
          a in Absent,
          where: a.absent_date == ^Date.utc_today() and a.student_id == ^student_id
        )
      )
    end

    Absent.changeset(%Absent{}, %{
      institution_id: institute_id,
      class_id: class_id,
      student_id: student_id,
      semester_id: semester_id,
      reason: absent_reason,
      absent_date: Date.utc_today()
    })
    |> Repo.insert()

    map =
      %{student: student.name, class: class.name, action: absent_reason, type: "warning"}
      |> Poison.encode!()

    send_resp(conn, 200, map)
  end

  def add_to_class_attendance(conn, %{
        "institute_id" => institute_id,
        "semester_id" => semester_id,
        "student_id" => student_id,
        "class_id" => class_id
      }) do
    class = Repo.get(Class, class_id)
    student = Repo.get(School.Affairs.Student, student_id)

    attendance =
      Repo.get_by(
        School.Affairs.Attendance,
        attendance_date: Date.utc_today(),
        class_id: class_id,
        semester_id: semester_id,
        institution_id: institute_id
      )

    student_ids = attendance.student_id |> String.split(",")

    if Enum.any?(student_ids, fn x -> x == student_id end) do
      student_ids = List.delete(student_ids, student_id) |> Enum.join(",")

      Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!()

      action = "has been marked as absent."
      type = "danger"
    else
      student_ids = List.insert_at(student_ids, 0, student_id) |> Enum.join(",")

      Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!()

      abs =
        Repo.all(
          from(
            a in Absent,
            where: a.absent_date == ^Date.utc_today() and a.student_id == ^student_id
          )
        )

      if abs != [] do
        Repo.delete_all(
          from(
            a in Absent,
            where: a.absent_date == ^Date.utc_today() and a.student_id == ^student_id
          )
        )
      end

      action = "has been marked as attended."
      type = "success"
    end

    map =
      %{student: student.name, class: class.name, action: action, type: type} |> Poison.encode!()

    send_resp(conn, 200, map)
  end

  def mark_attendance(conn, params) do
    class = Repo.get(Class, params["class_id"])

    attendance =
      Repo.get_by(
        Attendance,
        attendance_date: Date.utc_today(),
        class_id: class.id,
        semester_id: conn.private.plug_session["semester_id"]
      )

    if attendance == nil do
      cg =
        Attendance.changeset(%Attendance{}, %{
          institution_id: Affairs.inst_id(conn),
          attendance_date: Date.utc_today(),
          class_id: class.id,
          semester_id: conn.private.plug_session["semester_id"]
        })

      {:ok, attendance} = Repo.insert(cg)
    end

    students =
      Repo.all(
        from(
          s in Student,
          left_join: sc in StudentClass,
          on: sc.sudent_id == s.id,
          where:
            sc.institute_id == ^Affairs.inst_id(conn) and
              sc.semester_id == ^conn.private.plug_session["semester_id"] and
              sc.class_id == ^class.id
        )
      )

    student_ids = attendance.student_id |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    if student_ids != [] do
      attended_students =
        Repo.all(from(s in Student, where: s.id in ^student_ids, order_by: [s.name]))
    else
      attended_students = []
    end

    rem = students -- attended_students

    render(
      conn,
      "mark_attendance.html",
      class: class,
      attendance: attendance,
      students: rem,
      attended_students: attended_students
    )
  end

  def attendance_report(conn, params) do
    class_id = params["class"]
    semester_id = params["semester"]
    class = Repo.get(Class, class_id)
    params["month"]

    start_date =
      Date.new(String.to_integer(params["year"]), String.to_integer(params["month"]), 1)
      |> elem(1)

    end_date = Timex.end_of_month(start_date)

    students =
      Repo.all(
        from(
          s in StudentClass,
          left_join: t in Student,
          on: t.id == s.sudent_id,
          where:
            s.class_id == ^class_id and s.semester_id == ^semester_id and
              s.institute_id == ^conn.private.plug_session["institution_id"],
          select: %{sudent_id: s.sudent_id, name: t.name},
          order_by: [t.name]
        )
      )

    attendance =
      Repo.all(
        from(
          a in Attendance,
          where:
            a.class_id == ^class_id and
              a.institution_id == ^conn.private.plug_session["institution_id"] and
              a.semester_id == ^semester_id and a.attendance_date >= ^start_date and
              a.attendance_date <= ^end_date
        )
      )

    semester = Repo.get(Semester, semester_id)

    render(
      conn,
      "report.html",
      class: class,
      students: students,
      attendance: attendance,
      start_date: start_date,
      end_date: end_date
    )
  end

  def index(conn, _params) do
    attendance = Affairs.list_attendance()

    classes =
      Repo.all(
        from(
          c in Class,
          left_join: l in Level,
          on: c.level_id == l.id,
          where: c.institution_id == ^School.Affairs.inst_id(conn),
          select: %{id: c.id, level: l.name, class: c.name},
          order_by: [c.name]
        )
      )
      |> Enum.group_by(fn x -> x.level end)

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