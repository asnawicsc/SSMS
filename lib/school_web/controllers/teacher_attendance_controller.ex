defmodule SchoolWeb.TeacherAttendanceController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TeacherAttendance
  require IEx

  def index(conn, _params) do
    teacher_attendance =
      Affairs.list_teacher_attendance()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", teacher_attendance: teacher_attendance)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher_attendance(%TeacherAttendance{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teacher_attendance" => teacher_attendance_params}) do
    case Affairs.create_teacher_attendance(teacher_attendance_params) do
      {:ok, teacher_attendance} ->
        conn
        |> put_flash(:info, "Teacher attendance created successfully.")
        |> redirect(to: teacher_attendance_path(conn, :show, teacher_attendance))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)
    render(conn, "show.html", teacher_attendance: teacher_attendance)
  end

  def teacher_remark(conn, params) do
    render(conn, "teacher_remark.html")
  end

  def find_attandence(conn, params) do
    start_date = params["start_date"] |> String.split("-")

    s1 = start_date |> Enum.fetch!(0) |> String.to_integer() |> Integer.to_string()
    s2 = start_date |> Enum.fetch!(1) |> String.to_integer() |> Integer.to_string()
    s3 = start_date |> Enum.fetch!(2) |> String.to_integer() |> Integer.to_string()

    new_start_date = s1 <> "-" <> s2 <> "-" <> s3

    teachers_attend_full =
      Repo.all(
        from(s in School.Affairs.TeacherAttendance,
          left_join: g in School.Affairs.Teacher,
          on: s.teacher_id == g.id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"] and
              s.date == ^new_start_date,
          select: %{
            name: g.name,
            cname: g.cname,
            image_bin: g.image_bin,
            id: g.id,
            ta_id: s.id,
            time_in: s.time_in,
            time_out: s.time_out,
            date: s.date,
            alasan: s.alasan,
            remark: s.remark
          }
        )
      )
      |> Enum.filter(fn x -> x.time_in != nil end)
      |> Enum.filter(fn x -> x.time_out != nil end)

    teachers_attend =
      Repo.all(
        from(s in School.Affairs.TeacherAttendance,
          left_join: g in School.Affairs.Teacher,
          on: s.teacher_id == g.id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"] and
              s.date == ^new_start_date,
          select: %{
            name: g.name,
            cname: g.cname,
            image_bin: g.image_bin,
            id: g.id,
            ta_id: s.id,
            time_in: s.time_in,
            time_out: s.time_out,
            date: s.date,
            alasan: s.alasan,
            remark: s.remark
          }
        )
      )
      |> Enum.filter(fn x -> x.time_in == nil end)

    teachers_attend2 =
      Repo.all(
        from(s in School.Affairs.TeacherAttendance,
          left_join: g in School.Affairs.Teacher,
          on: s.teacher_id == g.id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"] and
              s.date == ^new_start_date,
          select: %{
            name: g.name,
            cname: g.cname,
            image_bin: g.image_bin,
            id: g.id,
            ta_id: s.id,
            time_in: s.time_in,
            time_out: s.time_out,
            date: s.date,
            alasan: s.alasan,
            remark: s.remark
          }
        )
      )
      |> Enum.filter(fn x -> x.time_out == nil end)

    not_finish = teachers_attend -- teachers_attend_full
    not_finish2 = teachers_attend2 -- teachers_attend_full

    render(conn, "find_attandence.html",
      teachers_attend_full: teachers_attend_full,
      not_finish: not_finish,
      not_finish2: not_finish2,
      new_start_date: new_start_date
    )
  end

  def teacher_attendence_mark(conn, params) do
    current_sem =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where: s.end_date > ^Timex.today() and s.start_date < ^Timex.today()
        )
      )

    date_time = NaiveDateTime.utc_now()

    date = NaiveDateTime.to_string(date_time) |> String.split_at(10) |> elem(0)

    year = date |> String.split_at(4) |> elem(0) |> String.to_integer()

    day = date |> String.split_at(8) |> elem(1) |> String.to_integer()

    m = date |> String.split_at(5) |> elem(1)

    month = m |> String.split_at(2) |> elem(0) |> String.to_integer()

    new_day = day |> Integer.to_string()
    new_month = month |> Integer.to_string()
    new_year = year |> Integer.to_string()

    date = new_day <> "-" <> new_month <> "-" <> new_year

    teachers_attend =
      Repo.all(
        from(
          t in Teacher,
          left_join: j in School.Affairs.TeacherAttendance,
          on: t.id == j.teacher_id,
          select: %{id: t.id},
          where:
            t.institution_id == ^conn.private.plug_session["institution_id"] and
              j.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    all =
      Repo.all(
        from(
          t in Teacher,
          select: %{id: t.id},
          where: t.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    not_yet = all -- teachers_attend

    not_yet_full =
      for item <- not_yet do
        teacher = Repo.get_by(Teacher, id: item.id)

        %{name: teacher.name, cname: teacher.cname, id: teacher.id}
      end

    # teachers_attend_full =
    #   for item <- teachers_attend do
    #     teacher = Repo.get_by(Teacher, id: item.id)

    #     teacher_attendance =
    #       Repo.get_by(School.Affairs.TeacherAttendance, teacher_id: item.id, date: date)

    #     teacher_attendance =
    #       if teacher_attendance != nil do
    #         %{
    #           name: teacher.name,
    #           cname: teacher.cname,
    #           image_bin: teacher.image_bin,
    #           id: teacher.id,
    #           time_in: teacher_attendance.time_in,
    #           time_out: teacher_attendance.time_out,
    #           date: teacher_attendance.date
    #         }
    #       else
    #         []
    #       end

    #     teacher_attendance
    #   end
    #   |> Enum.filter(fn x -> x != [] end)

    # teachers_attend_full =
    #   if teachers_attend_full != [] do
    #     teachers_attend_full |> Enum.filter(fn x -> x.date == date end)
    #   else
    #     []
    #   end

    teachers_attend_full =
      Repo.all(
        from(s in School.Affairs.TeacherAttendance,
          left_join: g in School.Affairs.Teacher,
          on: s.teacher_id == g.id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"] and g.id == ^params["id"],
          select: %{
            name: g.name,
            cname: g.cname,
            image_bin: g.image_bin,
            id: g.id,
            ta_id: s.id,
            time_in: s.time_in,
            time_out: s.time_out,
            date: s.date,
            alasan: s.alasan,
            remark: s.remark
          }
        )
      )

    changeset = Settings.change_institution(%Institution{})

    current_sem =
      if current_sem != [] do
        hd(current_sem)
      else
        %{start_date: "Not set", end_date: "Not set"}
      end

    institution = Settings.list_institutions()

    users = Settings.list_users()

    render(conn, "teacher_attendence_mark.html",
      current_sem: current_sem,
      institution: institution,
      users: users,
      changeset: changeset,
      not_yet: not_yet_full,
      teachers_attend: teachers_attend_full
    )
  end

  def edit_remark(conn, %{"id" => id}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)

    new_time_in =
      if teacher_attendance.time_in != nil do
        time_in =
          teacher_attendance.time_in
          |> String.split(" ")
          |> Enum.fetch!(1)
          |> String.split(":")

        ti1 = time_in |> Enum.fetch!(0)
        ti2 = time_in |> Enum.fetch!(1)
        ti3 = time_in |> Enum.fetch!(2)

        ti1 =
          if ti1 |> String.to_integer() <= 9 do
            "0" <> ti1
          else
            ti1
          end

        ti2 =
          if ti2 |> String.to_integer() <= 9 do
            "0" <> ti2
          else
            ti2
          end

        ti3 =
          if ti3 |> String.to_integer() <= 9 do
            "0" <> ti3
          else
            ti3
          end

        new_time_in = ti1 <> ":" <> ti2 <> ":" <> ti3
        new_time_in = new_time_in |> Time.from_iso8601!()
      else
        new_time_in = nil
      end

    new_time_out =
      if teacher_attendance.time_out != nil do
        time_out =
          teacher_attendance.time_out
          |> String.split(" ")
          |> Enum.fetch!(1)
          |> String.split(":")

        to1 = time_out |> Enum.fetch!(0)
        to2 = time_out |> Enum.fetch!(1)
        to3 = time_out |> Enum.fetch!(2)

        to1 =
          if to1 |> String.to_integer() <= 9 do
            "0" <> to1
          else
            to1
          end

        to2 =
          if to2 |> String.to_integer() <= 9 do
            "0" <> to2
          else
            to2
          end

        to3 =
          if to3 |> String.to_integer() <= 9 do
            "0" <> to3
          else
            to3
          end

        new_time_out = to3 <> ":" <> to2 <> ":" <> to1
        new_time_out = new_time_out |> Time.from_iso8601!()
      else
        new_time_out = nil
      end

    teacher_absent_reason =
      Repo.all(
        from(s in School.Affairs.TeacherAbsentReason,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: s.absent_reason
        )
      )

    render(conn, "edit_remark.html",
      teacher_attendance: teacher_attendance,
      teacher_absent_reason: teacher_absent_reason,
      new_time_out: new_time_out,
      new_time_in: new_time_in,
      id: id
    )
  end

  def update_teacher_remark(conn, params) do
    id = params["id"]

    teacher_attendance = Affairs.get_teacher_attendance!(id)

    date = teacher_attendance.date

    time_in =
      if params["time_in"] != "" do
        date <> " " <> params["time_in"]
      else
      end

    time_out =
      if params["time_out"] != "" do
        date <> " " <> params["time_out"]
      else
      end

    alasan =
      if params["remark"] != "Choose a Remark" do
        params["remark"]
      else
      end

    teacher_attendance_params = %{time_in: time_in, time_out: time_out, alasan: alasan}

    Affairs.update_teacher_attendance(teacher_attendance, teacher_attendance_params)

    conn
    |> put_flash(:info, "Teacher attendance updated successfully.")
    |> redirect(to: teacher_attendance_path(conn, :teacher_remark))
  end

  def edit(conn, %{"id" => id}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)
    changeset = Affairs.change_teacher_attendance(teacher_attendance)

    teacher_absent_reason =
      Repo.all(
        from(s in School.Affairs.TeacherAbsentReason,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: s.absent_reason
        )
      )

    render(conn, "edit.html",
      teacher_attendance: teacher_attendance,
      changeset: changeset,
      teacher_absent_reason: teacher_absent_reason
    )
  end

  def teacher_attendence_report(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "teacher_attendence_report.html", semesters: semesters)
  end

  def update(conn, %{"id" => id, "teacher_attendance" => teacher_attendance_params}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)

    case Affairs.update_teacher_attendance(teacher_attendance, teacher_attendance_params) do
      {:ok, teacher_attendance} ->
        conn
        |> put_flash(:info, "Teacher attendance updated successfully.")
        |> redirect(
          to:
            teacher_attendance_path(conn, :teacher_attendence_mark, teacher_attendance.teacher_id)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_attendance: teacher_attendance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_attendance = Affairs.get_teacher_attendance!(id)
    {:ok, _teacher_attendance} = Affairs.delete_teacher_attendance(teacher_attendance)

    conn
    |> put_flash(:info, "Teacher attendance deleted successfully.")
    |> redirect(to: teacher_attendance_path(conn, :index))
  end
end
