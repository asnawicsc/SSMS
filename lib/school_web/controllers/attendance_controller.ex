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

  def class_attendance(conn, params) do
    events =
      case School.Affairs.get_class!(params["class_id"]) do
        class ->
          IEx.pry()
          School.Affairs.all_attandence(class.id)

        {:error, message} ->
          []
      end
      |> Poison.encode!()

    IEx.pry()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, events)
  end

  def add_to_class_attendance(conn, %{
        "institute_id" => institute_id,
        "semester_id" => semester_id,
        "student_id" => student_id,
        "class_id" => class_id
      }) do
    class = Repo.get(Class, class_id)
    student = Repo.get(School.Affairs.Student, student_id)
    IO.inspect(student)

    attendance =
      Repo.get_by(
        School.Affairs.Attendance,
        attendance_date: Date.utc_today(),
        class_id: class_id,
        semester_id: semester_id,
        institution_id: institute_id
      )

    student_ids = attendance.student_id |> String.split(",")

    {action, type} =
      if Enum.any?(student_ids, fn x -> x == student_id end) do
        student_ids = List.delete(student_ids, student_id) |> Enum.join(",")

        Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!()

        {"has been marked as absent.", "danger"}
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

        {"has been marked as attended.", "success"}
      end

    map =
      %{student: student.name, class: class.name, action: action, type: type} |> Poison.encode!()

    send_resp(conn, 200, map)
  end

  def mark_attendance(conn, params) do
    holiday = Repo.get_by(School.Affairs.Holiday, date: params["date"])

    if holiday == nil do
      class =
        Repo.get_by(
          Class,
          id: params["class_id"],
          institution_id: conn.private.plug_session["institution_id"]
        )

      attendance =
        Repo.get_by(
          Attendance,
          attendance_date: params["date"],
          class_id: params["class_id"],
          semester_id: conn.private.plug_session["semester_id"],
          institution_id: conn.private.plug_session["institution_id"]
        )

      {attendance} =
        if attendance == nil do
          cg =
            Attendance.changeset(%Attendance{}, %{
              institution_id: Affairs.inst_id(conn),
              attendance_date: params["date"],
              class_id: params["class_id"],
              semester_id: conn.private.plug_session["semester_id"]
            })

          {:ok, attendance} = Repo.insert(cg)
          {attendance}
        else
          {Repo.get_by(
             Attendance,
             attendance_date: params["date"],
             class_id: params["class_id"],
             semester_id: conn.private.plug_session["semester_id"]
           )}
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
                s.institution_id == ^conn.private.plug_session["institution_id"] and
                sc.class_id == ^params["class_id"],
            order_by: [s.name]
          )
        )

      student_ids = attendance.student_id |> String.split(",") |> Enum.reject(fn x -> x == "" end)

      attended_students =
        if student_ids != [] do
          Repo.all(from(s in Student, where: s.id in ^student_ids, order_by: [s.name]))
        else
          []
        end

      rem = students -- attended_students

      rem =
        for each <- rem do
          Map.put(each, :attend, false)
        end

      attended_students =
        if attended_students != [] do
          attended_students =
            for each <- attended_students do
              Map.put(each, :attend, true)
            end
        else
          []
        end

      students = List.flatten(rem, attended_students)

      render(
        conn,
        "mark_attendance2.html",
        class: class,
        attendance: attendance,
        students: students,
        date: params["date"]
      )
    else
      conn
      |> put_flash(:info, "This Date is reserveed for #{holiday.description} ")
      |> redirect(to: attendance_path(conn, :index))
    end
  end

  def record_attendance(conn, params) do
    attendance = Repo.get(Attendance, params["attendance_id"])
    lists = Map.to_list(params)

    student_ids =
      for list <- lists do
        if String.contains?(elem(list, 0), "-attend") do
          params[elem(list, 0)]
        end
      end
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.join(",")

    Attendance.changeset(attendance, %{student_id: student_ids}) |> Repo.update!()

    abs_ids =
      for list <- lists do
        if String.contains?(elem(list, 0), "-abs_reason") do
          String.trim(elem(list, 0), "-abs_reason")
        end
      end
      |> Enum.filter(fn x -> x != nil end)

    if abs_ids == "" do
      conn
      |> put_flash(:info, "Attendance inserted fail, please mark all students.")
      |> redirect(to: attendance_path(conn, :index))
    end

    attended_std = student_ids |> String.split(",")
    inform_parents_student_attendance(attended_std)
    abs_ids = abs_ids -- attended_std

    for each <- abs_ids do
      abs = Repo.get_by(Absent, absent_date: attendance.attendance_date, student_id: each)

      if abs != nil do
        Absent.changeset(abs, %{reason: params[each <> "-abs_reason"]}) |> Repo.update!()
      else
        Absent.changeset(%Absent{}, %{
          institution_id: attendance.institution_id,
          class_id: attendance.class_id,
          student_id: each,
          semester_id: attendance.semester_id,
          reason: params[each <> "-abs_reason"],
          absent_date: attendance.attendance_date
        })
        |> Repo.insert()
      end
    end

    conn
    |> put_flash(:info, "Attendance recorded successfully.")
    |> redirect(to: attendance_path(conn, :index))
  end

  def inform_parents_student_attendance(attended_std) do
    if attended_std != [] do
      for id <- attended_std do
        if id != "" do
          student = Affairs.get_student!(id)
          IO.inspect(student)

          guardian =
            if student.gicno != nil do
              Repo.get_by(Parent, icno: student.gicno)
            else
              nil
            end

          father =
            if student.ficno != nil do
              Repo.get_by(Parent, icno: student.ficno)
            else
              nil
            end

          mother =
            if student.micno != nil do
              Repo.get_by(Parent, icno: student.micno)
            else
              nil
            end

          cond do
            guardian != nil ->
              fb_send_attedance_report(guardian, student)

            father != nil ->
              fb_send_attedance_report(father, student)

            mother != nil ->
              fb_send_attedance_report(mother, student)

            true ->
              nil
          end
        end
      end
    end
  end

  def fb_send_attedance_report(parent, student) do
    IO.inspect(parent)

    date =
      DateTime.utc_now()
      |> Timex.shift(hours: 8)
      |> Timex.format("%Y-%m-%d %H:%M ", :strftime)
      |> elem(1)

    if parent.fb_user_id != nil do
      SchoolWeb.ApiController.personal_broadcast(
        "attendance_announcement",
        [
          %{name: student.name},
          %{date: date},
          %{message: "is present during teacher taking attendance."}
        ],
        parent.psid
      )
    end
  end

  def attendance_report(conn, params) do
    class_id = params["class"]
    semester_id = params["semester"]
    class = Repo.get(Class, class_id)
    params["month"]
    year = params["year"]

    start_date =
      Date.new(String.to_integer(params["year"]), String.to_integer(params["month"]), 1)
      |> elem(1)

    end_date = Timex.end_of_month(start_date)

    range = start_date.day..end_date.day

    all =
      for item <- range do
        item
      end

    st = all |> Enum.filter(fn x -> x <= 16 end)
    nd = all |> Enum.filter(fn x -> x > 16 and x <= 31 end)

    start_month = st |> List.first()
    half_month = st |> List.last()
    start_2half = nd |> List.first()
    end_month = nd |> List.last()

    students =
      Repo.all(
        from(
          s in StudentClass,
          left_join: t in Student,
          on: t.id == s.sudent_id,
          where:
            s.class_id == ^class_id and s.semester_id == ^semester_id and
              s.institute_id == ^conn.private.plug_session["institution_id"],
          select: %{
            sudent_id: s.sudent_id,
            name: t.name,
            chinese_name: t.chinese_name,
            sex: t.sex,
            id: t.id
          },
          order_by: [t.name]
        )
      )
      |> Enum.reject(fn x -> x.sudent_id == "" end)

    IO.inspect(students)

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

    estimate_total = (all |> Enum.count()) * (students |> Enum.count())

    semester = Repo.get(Semester, semester_id)

    # render(
    #   conn,
    #   "report.html",
    #   class: class,
    #   students: students,
    #   attendance: attendance,
    #   start_date: start_date,
    #   end_date: end_date,
    #   start_month: Date.new(String.to_integer(params["year"]), String.to_integer(params["month"]), start_month)|> elem(1),
    #   half_month: Date.new(String.to_integer(params["year"]), String.to_integer(params["month"]), half_month)|> elem(1),
    #   start_2half: Date.new(String.to_integer(params["year"]), String.to_integer(params["month"]), start_2half)|> elem(1),
    #   end_month: Date.new(String.to_integer(params["year"]), String.to_integer(params["month"]), end_month)|> elem(1),
    #   estimate_total: estimate_total
    # )

    institution =
      Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.AttendanceView,
        "report.html",
        conn: conn,
        year: year,
        class: class,
        students: students,
        attendance: attendance,
        start_date: start_date,
        end_date: end_date,
        semester_id: semester_id,
        institution: institution,
        start_month:
          Date.new(
            String.to_integer(params["year"]),
            String.to_integer(params["month"]),
            start_month
          )
          |> elem(1),
        half_month:
          Date.new(
            String.to_integer(params["year"]),
            String.to_integer(params["month"]),
            half_month
          )
          |> elem(1),
        start_2half:
          Date.new(
            String.to_integer(params["year"]),
            String.to_integer(params["month"]),
            start_2half
          )
          |> elem(1),
        end_month:
          Date.new(
            String.to_integer(params["year"]),
            String.to_integer(params["month"]),
            end_month
          )
          |> elem(1),
        estimate_total: estimate_total
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8",
          "--orientation",
          "Portrait"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def index(conn, _params) do
    user_id = conn.private.plug_session["user_id"]

    user = Repo.get_by(School.Settings.User, %{id: user_id})

    {attendance, classes, list} =
      if user.role == "Admin" or user.role == "Support" do
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

        list_class_holiday =
          Repo.all(
            from(
              p in School.Affairs.Holiday,
              where: p.institution_id == ^conn.private.plug_session["institution_id"],
              select: %{
                start: p.date,
                title: p.description,
                color: "#ff9f89"
              }
            )
          )

        list_class_attendence =
          Repo.all(
            from(p in School.Affairs.Attendance,
              left_join: s in School.Affairs.Class,
              on: p.class_id == s.id,
              where:
                p.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.institution_id == ^conn.private.plug_session["institution_id"],
              select: %{
                start: p.attendance_date,
                title: s.name,
                color: "yellow",
                student_id: p.student_id
              }
            )
          )
          |> Enum.group_by(fn x -> {x.start, x.title} end)

        list_class_attendence =
          for item <- list_class_attendence do
            for ar <- item |> elem(1) do
              count = ar.student_id |> String.split(",") |> Enum.count() |> Integer.to_string()

              title = ar.title

              class =
                Repo.get_by(School.Affairs.Class,
                  name: title,
                  institution_id: conn.private.plug_session["institution_id"]
                )

              student_class =
                Repo.all(
                  from(s in School.Affairs.StudentClass,
                    where:
                      s.institute_id == ^conn.private.plug_session["institution_id"] and
                        s.semester_id == ^conn.private.plug_session["semester_id"] and
                        s.class_id == ^class.id
                  )
                )
                |> Enum.count()
                |> Integer.to_string()

              b = title <> "-" <> count <> "/" <> student_class

              date = ar.start
              color = ar.color

              %{start: date, title: b, color: color}
            end
          end
          |> List.flatten()

        list =
          (list_class_attendence ++ list_class_holiday)
          |> Poison.encode!()

        {attendance, classes, list}
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

        # class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})
        class = Repo.all(from(c in Class, where: c.teacher_id == ^teacher.id))

        if class == [] do
          conn
          |> put_flash(:info, "You are not assign to any class")
          |> redirect(to: page_path(conn, :index))
        end

        list_class_holiday =
          Repo.all(
            from(p in School.Affairs.Holiday,
              where: p.institution_id == ^conn.private.plug_session["institution_id"],
              select: %{
                start: p.date,
                title: p.description,
                color: "#ff9f89"
              }
            )
          )

        list_class_attendence =
          Repo.all(
            from(p in School.Affairs.Attendance,
              left_join: s in School.Affairs.Class,
              on: p.class_id == s.id,
              where:
                p.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.institution_id == ^conn.private.plug_session["institution_id"],
              select: %{
                start: p.attendance_date,
                title: s.name,
                color: "yellow"
              }
            )
          )
          |> Enum.group_by(fn x -> {x.title, x.start} end)

        list_class_attendence =
          for item <- list_class_attendence do
            count = item |> elem(1) |> Enum.count()
            title = item |> elem(0) |> elem(0)
            date = item |> elem(0) |> elem(1)
            color = "green"

            a = count |> Integer.to_string()
            b = title <> "  Total Attend: " <> a

            %{start: date, title: b, color: "yellow"}
          end

        list =
          (list_class_attendence ++ list_class_holiday)
          |> Poison.encode!()

        attendance =
          for each_class <- class do
            Affairs.list_attendance() |> Enum.filter(fn x -> x.class_id == each_class.id end)
          end

        classes =
          for each_class <- class do
            Repo.all(
              from(
                c in Class,
                left_join: l in Level,
                on: c.level_id == l.id,
                where:
                  c.institution_id == ^School.Affairs.inst_id(conn) and c.id == ^each_class.id,
                select: %{id: c.id, level: l.name, class: c.name},
                order_by: [c.name]
              )
            )
          end
          |> List.flatten()
          |> Enum.group_by(fn x -> x.level end)

        {attendance, classes, list}
      end

    render(conn, "index.html",
      attendance: attendance,
      classes: classes,
      list_class_attendence: list
    )
  end

  def generate_attendance_report(conn, params) do
    attendance = Affairs.list_attendance()

    user = Repo.get_by(School.Settings.User, %{id: conn.private.plug_session["user_id"]})

    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    # class =
    # if teacher != nil do
    #  Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})
    # end

    classes =
      if user.role == "Admin" or user.role == "Support" do
        Repo.all(
          from(
            c in School.Affairs.Class,
            left_join: l in School.Affairs.Level,
            on: c.level_id == l.id,
            where: c.institution_id == ^School.Affairs.inst_id(conn),
            select: %{id: c.id, level: l.name, class: c.name},
            order_by: [c.name]
          )
        )
        |> Enum.group_by(fn x -> x.level end)
      else
        Repo.all(
          from(
            c in School.Affairs.Class,
            left_join: l in School.Affairs.Level,
            on: c.level_id == l.id,
            where:
              c.institution_id == ^School.Affairs.inst_id(conn) and c.teacher_id == ^teacher.id,
            select: %{id: c.id, level: l.name, class: c.name},
            order_by: [c.name]
          )
        )
        |> Enum.group_by(fn x -> x.level end)
      end

    render(conn, "generate_attendance_report.html", attendance: attendance, classes: classes)
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
