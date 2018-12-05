defmodule SchoolWeb.ClassController do
  use SchoolWeb, :controller
  use Task

  require IEx

  def class_transfer(conn, params) do
    all_classes =
      Repo.all(
        from(
          c in Class,
          left_join: l in Level,
          on: l.id == c.level_id,
          where: c.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            id: c.id,
            class_name: c.name,
            next_class: c.next_class,
            level_name: l.name,
            level_id: l.id
          }
        )
      )
      |> Enum.group_by(fn x -> x.level_name end)

    render(conn, "class_transfer.html", classes: all_classes)
  end

  def submit_class_transfer(conn, params) do
    for each <- params do
      if elem(each, 1) != "Graduate" do
        cur_class = elem(each, 1) |> String.split("->") |> List.to_tuple() |> elem(0)
        next_class = elem(each, 1) |> String.split("->") |> List.to_tuple() |> elem(1)
        cur_class = Repo.get(Class, cur_class)
        class_params = %{next_class: next_class}

        Affairs.update_class(cur_class, class_params)
      else
        cur_class = elem(each, 1) |> String.split("->") |> List.to_tuple() |> elem(0)
        cur_class = Repo.get(Class, cur_class)
        class_params = %{next_class: "Graduate"}

        Affairs.update_class(cur_class, class_params)
      end
    end

    conn
    |> put_flash(:info, "Class transfer settings updated.")
    |> redirect(to: class_path(conn, :class_transfer))
  end

  def mark_sheet_listing(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    classes =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    exams =
      Repo.all(
        from(
          e in ExamMaster,
          where: e.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    render(conn, "mark_sheet_listing.html", semesters: semesters, classes: classes, exams: exams)
  end

  def mark_analyse_by_grade(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    classes =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    render(conn, "mark_analyse_by_grade.html", semesters: semesters, classes: classes)
  end

  def height_weight_report(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "hw_details.html", semesters: semesters)
  end

  def class_analysis(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    classes =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    render(conn, "class_analysis.html", semesters: semesters, classes: classes)
  end

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
            phone: t.phone,
            b_cert: t.b_cert
          }
        )
      )

    inst = Repo.get(Institution, School.Affairs.inst_id(conn))

    uri = Application.get_env(:school, :api)[:url]
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

    ic =
      if student.ic == nil do
        student.b_cert
      else
        student.ic
      end

    phone =
      if student.phone == nil do
        "no_phone"
      else
        student.phone
      end

    path =
      "?scope=get_user_register_response&lib_id=#{lib_id}&name=#{name}&ic=#{ic}&phone=#{phone}&code=#{
        student.student_no
      }"

    IO.inspect(uri <> path)
    response = HTTPoison.get!(uri <> path, [{"Content-Type", "application/json"}]).body
  end

  def edit_class(conn, params) do
    class = Affairs.get_class!(params["edit_class"])

    class_params = %{
      remarks: params["remark"],
      name: params["class_name"],
      teacher_id: params["teacher_id"]
    }

    case Affairs.update_class(class, class_params) do
      {:ok, class} ->
        conn
        |> put_flash(:info, "Class updated successfully.")
        |> redirect(to: class_path(conn, :class_setting))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", class: class, changeset: changeset)
    end
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

  def chosen_class_setting(conn, params) do
    changeset = Affairs.change_class(%Class{})
    institution_id = conn.private.plug_session["institution_id"]
    class_id = params["class_id"]

    class =
      Repo.all(
        from(
          c in Class,
          left_join: l in Level,
          on: c.level_id == l.id,
          left_join: i in Institution,
          on: c.institution_id == i.id,
          where: c.id == ^class_id,
          select: %{
            name: c.name,
            level: l.name,
            teacher_id: c.teacher_id,
            remark: c.remarks,
            institution: i.name
          }
        )
      )
      |> hd()

    teacher =
      if class.teacher_id == nil do
        teacher = "No Teacher"
        teacher
      else
        a = Repo.get(Teacher, class.teacher_id)
        teacher = a.name

        teacher
      end

    students =
      Repo.all(
        from(
          st in StudentClass,
          left_join: s in Student,
          on: s.id == st.sudent_id,
          where:
            st.class_id == ^class_id and
              st.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            id: st.sudent_id,
            name: s.name
          },
          order_by: [asc: s.name]
        )
      )

    subject_class =
      Repo.all(
        from(
          s in SubjectTeachClass,
          left_join: g in Subject,
          on: s.subject_id == g.id,
          where:
            s.class_id == ^class_id and
              g.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{s_name: g.description, s_id: s.subject_id, c_id: s.class_id}
        )
      )

    render(
      conn,
      "chosen_class_setting.html",
      teacher: teacher,
      class: class,
      class_id: class_id,
      changeset: changeset,
      institution_id: institution_id,
      students: students,
      subject_class: subject_class
    )
  end

  def modify_timetable(conn, params) do
    inst_id = Affairs.get_inst_id(conn)
    teachers = Affairs.list_teacher(inst_id)
    subjects = Affairs.list_subject(inst_id)
    class = Repo.get(Class, params["class_id"])
    render(conn, "modify_timetable.html", class: class, teachers: teachers, subjects: subjects)
  end

  def enroll_students(conn, params) do
    inst_id = Affairs.get_inst_id(conn)
    classes = Affairs.list_classes(inst_id)
    semesters = Affairs.list_semesters(inst_id)
    render(conn, "enroll_students.html", classes: classes, semesters: semesters)
  end

  def show_student_info(conn, params) do
    student = Repo.get(Student, params["student_id"])

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

    render(
      conn,
      "show_student_info.html",
      student: student
    )
  end

  def class_setting(conn, params) do
    changeset = Affairs.change_class(%Class{})

    user = Repo.get(User, conn.private.plug_session["user_id"])

    if user.role == "Teacher" do
      teacher = Repo.all(from(t in Teacher, where: t.email == ^user.email))

      if teacher != nil do
        teacher = teacher |> hd()

        class =
          Repo.all(
            from(
              c in Class,
              where: c.teacher_id == ^teacher.id,
              select: %{id: c.id, name: c.name}
            )
          )
      end
    end

    class =
      if user.role == "Admin" or user.role == "Support" do
        Repo.all(
          from(
            c in Class,
            left_join: l in Level,
            on: c.level_id == l.id,
            where: c.institution_id == ^conn.private.plug_session["institution_id"],
            select: %{id: c.id, name: c.name, level_name: l.name}
          )
        )
      end

    levels =
      Affairs.list_levels()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    institution_id = conn.private.plug_session["institution_id"]

    render(
      conn,
      "class_setting.html",
      class: class,
      levels: levels,
      changeset: changeset,
      institution_id: institution_id
    )
  end

  def student_listing_by_class(conn, params) do
    user = Repo.get_by(School.Settings.User, %{id: conn.private.plug_session["user_id"]})

    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    ad =
      if teacher != nil do
        Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})
      end

    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    class =
      if user.role == "Admin" or user.role == "Support" do
        Repo.all(
          from(
            s in School.Affairs.Class,
            select: %{institution_id: s.institution_id, id: s.id, name: s.name}
          )
        )
        |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
      else
        Repo.all(
          from(
            s in School.Affairs.Class,
            where: s.id == ^ad.id,
            select: %{institution_id: s.institution_id, id: s.id, name: s.name}
          )
        )
        |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
      end

    render(
      conn,
      "student_listing_by_class.html",
      class: class,
      semesters: semesters
    )
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

  def create_class_period(conn, params) do
    class_id = params["class_id"]
    subject = params["subject"]
    day = params["day"]
    end_time = params["end_time"] |> String.reverse()
    start_time = params["start_time"] |> String.reverse()

    a = "00:"
    new_end_time = (a <> end_time) |> String.reverse() |> Time.from_iso8601!()
    new_start_time = (a <> start_time) |> String.reverse() |> Time.from_iso8601!()

    n_time = new_start_time.hour
    n_sm = new_start_time.minute
    e_time = new_end_time.hour
    n_em = new_start_time.minute

    if n_time == 0 do
      n_time = 12
    end

    if e_time == 0 do
      e_time = 12
    end

    subject = Repo.get_by(School.Affairs.SubjectTeachClass, id: subject)
    class = Repo.get_by(Class, id: class_id)
    teacher = Repo.get_by(Teacher, id: subject.teacher_id)
    subject_period = Repo.get_by(Subject, id: subject.subject_id)

    params = %{
      day: day,
      end_time: new_end_time,
      start_time: new_start_time,
      teacher_id: teacher.id,
      class_id: class.id,
      subject_id: subject_period.id
    }

    period_class =
      Repo.all(from(p in School.Affairs.Period, where: p.class_id == ^class.id and p.day == ^day))

    all =
      for item <- period_class do
        e = item.end_time.hour
        s = item.start_time.hour
        em = item.end_time.minute
        sm = item.start_time.minute

        if e == 0 do
          e = 12
        end

        if s == 0 do
          s = 12
        end

        %{end_time: e, start_time: s, start_minute: sm, end_minute: em}
      end

    a =
      all
      |> Enum.filter(fn x ->
        x.start_time >= n_time and x.start_time <= e_time and x.start_minute >= n_sm and
          x.start_minute <= n_em
      end)

    b = a |> Enum.count()

    if b == 0 do
      case Affairs.create_period(params) do
        {:ok, period} ->
          conn
          |> put_flash(:info, "Period created successfully.")
          |> redirect(to: class_path(conn, :class_setting))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:info, "That slot already been taken,please refer to period table.")
      |> redirect(to: class_path(conn, :class_setting))
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

  def create_class(conn, params) do
    changeset = Affairs.change_class(%Class{})
    render(conn, "create_class.html", changeset: changeset)
  end

  def create(conn, %{"class" => class_params}) do
    class_params =
      Map.put(class_params, "institution_id", conn.private.plug_session["institution_id"])

    case Affairs.create_class(class_params) do
      {:ok, class} ->
        conn
        |> put_flash(:info, "Class created successfully.")
        |> redirect(to: class_path(conn, :index))

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

  def pre_upload_class(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.create_batch(%{upload_by: usr.id, result: bin})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)

    render(conn, "adjust_header.html", headers: headers, batch_id: batch.id)
  end

  def upload_class(conn, params) do
    batch = Settings.get_batch!(params["batch_id"])
    bin = batch.result
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.update_batch(batch, %{upload_by: usr.id})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers =
      hd(data)
      |> Enum.map(fn x -> String.trim(x, " ") end)
      |> Enum.map(fn x -> params["header"][x] end)

    contents = tl(data) |> Enum.uniq() |> Enum.sort()

    result =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

        content = content |> Enum.map(fn x -> x end) |> Enum.filter(fn x -> x != "\"" end)

        c =
          for item <- content do
            item =
              case item do
                "@@@" ->
                  ","

                "\\N" ->
                  ""

                _ ->
                  item
              end

            a =
              case item do
                {:ok, i} ->
                  i

                _ ->
                  cond do
                    item == " " ->
                      "null"

                    item == "  " ->
                      "null"

                    item == "   " ->
                      "null"

                    true ->
                      item
                      |> String.split("\"")
                      |> Enum.map(fn x -> String.replace(x, "\n", "") end)
                      |> List.last()
                  end
              end
          end

        class_param = Enum.zip(h, c) |> Enum.into(%{})

        class_param =
          Map.put(class_param, "institution_id", conn.private.plug_session["institution_id"])

        cg = Class.changeset(%Class{}, class_param)

        case Repo.insert(cg) do
          {:ok, class} ->
            class_param
            class_param = Map.put(class_param, "reason", "ok")

          {:error, changeset} ->
            errors = changeset.errors |> Keyword.keys()

            {reason, message} = changeset.errors |> hd()
            {proper_message, message_list} = message
            final_reason = Atom.to_string(reason) <> " " <> proper_message
            class_param = Map.put(class_param, "reason", final_reason)

            class_param
        end
      end

    header = result |> hd() |> Map.keys()
    body = result |> Enum.map(fn x -> Map.values(x) end)
    new_io = List.insert_at(body, 0, header) |> CSV.encode() |> Enum.to_list() |> to_string
    {:ok, batch} = Settings.update_batch(batch, %{result: new_io})

    conn
    |> put_flash(:info, "Student created successfully.")
    |> redirect(to: student_path(conn, :index))
  end
end
