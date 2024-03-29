defmodule SchoolWeb.TeacherController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Teacher
  alias School.Settings.User
  alias School.Settings.UserAccess
  require IEx
  import Mogrify

  def index(conn, _params) do
    teacher =
      Affairs.list_teacher()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
      |> Enum.filter(fn x -> x.is_delete != 1 end)

    render(conn, "index.html", teacher: teacher)
  end

  def e_discipline(conn, params) do
    user = Repo.get(User, conn.private.plug_session["user_id"])

    teacher =
      if user.role == "Teacher" do
        teacher = Repo.get_by(Teacher, email: user.email)
      end

    messages = Repo.all(from(e in School.Affairs.Ediscipline, where: e.teacher_id == ^teacher.id))
    render(conn, "e_discipline.html", messages: messages)
  end

  def teacher_attendances(conn, params) do
    date_time = NaiveDateTime.utc_now()

    date = NaiveDateTime.to_string(date_time) |> String.split_at(10) |> elem(0)

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

    teachers_attend_full =
      for item <- teachers_attend do
        teacher = Repo.get_by(Teacher, id: item.id)

        teacher_attendance =
          Repo.get_by(School.Affairs.TeacherAttendance, teacher_id: item.id, date: date)

        %{
          name: teacher.name,
          cname: teacher.cname,
          id: teacher.id,
          time_in: teacher_attendance.time_in,
          time_out: teacher_attendance.time_out
        }
      end

    render(
      conn,
      "teacher_attendances.html",
      not_yet: not_yet_full,
      teachers_attend: teachers_attend_full
    )
  end

  def edit_teacher_access(conn, params) do
    user = Repo.get_by(User, id: params["user_id"])

    crypted_password = Comeonin.Bcrypt.hashpwsalt(params["password"])

    params = Map.put(params, "password", params["password"])
    params = Map.put(params, "crypted_password", crypted_password)
    params = Map.put(params, "name", params["name"])

    case Settings.update_user(user, params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: teacher_path(conn, :index))

      {:error} ->
        render(conn, "edit_teacher_login.html", user: user)
    end
  end

  def delete_teacher_login(conn, params) do
    user = Settings.get_user!(params["id"])

    user_access = Repo.get_by(School.Settings.UserAccess, user_id: user.id)
    Settings.delete_user_access(user_access)
    Settings.delete_user(user)

    conn
    |> put_flash(:info, "Teacher Login successfully deleted.")
    |> redirect(to: teacher_path(conn, :index))
  end

  def mark_teacher_attendance(conn, params) do
    date = params["date"]

    teachers =
      Repo.all(
        from(
          t in Teacher,
          where: t.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    attendance =
      Repo.get_by(
        Attendance,
        attendance_date: params["date"],
        class_id: 0,
        semester_id: conn.private.plug_session["semester_id"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    {attendance} =
      if attendance == nil do
        cg =
          Attendance.changeset(%Attendance{}, %{
            institution_id: Affairs.inst_id(conn),
            attendance_date: params["date"],
            class_id: 0,
            semester_id: conn.private.plug_session["semester_id"]
          })

        {:ok, attendance} = Repo.insert(cg)
        {attendance}
      else
        {Repo.get_by(
           Attendance,
           attendance_date: params["date"],
           class_id: 0,
           semester_id: conn.private.plug_session["semester_id"]
         )}
      end

    attended_teacher_ids =
      attendance.teacher_id |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    attended_teachers =
      if attended_teacher_ids != [] do
        Repo.all(from(s in Teacher, where: s.id in ^attended_teacher_ids, order_by: [s.name]))
      else
        []
      end

    remaining = teachers -- attended_teachers

    remaining =
      for each <- remaining do
        Map.put(each, :attend, false)
      end

    attended_teachers =
      if attended_teachers != [] do
        attended_teachers =
          for each <- attended_teachers do
            Map.put(each, :attend, true)
          end
      else
        attended_teachers = []
      end

    teachers = List.flatten(remaining, attended_teachers)

    render(
      conn,
      "mark_teacher_attendance.html",
      date: date,
      teachers: teachers,
      attendance: attendance
    )
  end

  def submit_teacher_attendance(conn, params) do
    attendance = Repo.get(Attendance, params["attendance_id"])
    lists = Map.to_list(params)

    teacher_ids =
      for list <- lists do
        if String.contains?(elem(list, 0), "-attend") do
          params[elem(list, 0)]
        end
      end
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.join(",")

    if teacher_ids == "" do
      conn
      |> put_flash(:info, "Attendance inserted fail, please mark all teacher.")
      |> redirect(to: teacher_path(conn, :teacher_attendance))
    end

    Attendance.changeset(attendance, %{teacher_id: teacher_ids}) |> Repo.update!()

    abs_ids =
      for list <- lists do
        if String.contains?(elem(list, 0), "-abs_reason") do
          String.trim(elem(list, 0), "-abs_reason")
        end
      end
      |> Enum.filter(fn x -> x != nil end)

    attended_teacher = teacher_ids |> String.split(",")
    abs_ids = abs_ids -- attended_teacher

    for each <- abs_ids do
      abs = Repo.get_by(Absent, absent_date: attendance.attendance_date, teacher_id: each)

      if abs != nil do
        Absent.changeset(abs, %{reason: params[each <> "-abs_reason"]}) |> Repo.update!()
      else
        Absent.changeset(%Absent{}, %{
          institution_id: attendance.institution_id,
          class_id: 0,
          teacher_id: each,
          semester_id: attendance.semester_id,
          reason: params[each <> "-abs_reason"],
          absent_date: attendance.attendance_date
        })
        |> Repo.insert()
      end
    end

    conn
    |> put_flash(:info, "Attendance recorded successfully.")
    |> redirect(to: teacher_path(conn, :teacher_attendance))
  end

  def teacher_setting(conn, _params) do
    teacher_school_job =
      Affairs.list_teacher_school_job()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    teacher_co_curriculum_job =
      Affairs.list_teacher_co_curriculum_job()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    teacher_hem_job =
      Affairs.list_teacher_hem_job()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    teacher =
      Affairs.list_teacher()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
      |> Enum.filter(fn x -> x.name != "Rehat" end)

    school_job =
      Affairs.list_school_job()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    co_curriculum_job =
      Affairs.list_cocurriculum_job()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    hem_job =
      Affairs.list_hem_job()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    absent_reason =
      Affairs.list_absent_reason()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(
      conn,
      "teacher_setting.html",
      teacher_hem_job: teacher_hem_job,
      teacher_co_curriculum_job: teacher_co_curriculum_job,
      teacher_school_job: teacher_school_job,
      teacher: teacher,
      school_job: school_job,
      co_curriculum_job: co_curriculum_job,
      hem_job: hem_job,
      absent_reason: absent_reason
    )
  end

  def signiture_upload(conn, params) do
    render(conn, "signiture_upload.html")
  end

  def upload_signiture(conn, params) do
    image_params = params["item"]["file"]

    institution = Settings.get_institution!(conn.private.plug_session["institution_id"])
    institution_params = %{}

    institution_params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        institution_params = Map.put(institution_params, :hm_bin, result.bin)
      else
        institution
      end

    institution_params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        institution_params = Map.put(institution_params, :hm_filename, result.filename)
      else
        institution
      end

    Settings.update_institution(institution, institution_params)

    conn
    |> put_flash(:info, "Upload HM succesfully.")
    |> redirect(to: page_path(conn, :support_dashboard))
  end

  def create_teacher_login(conn, params) do
    teacher =
      Repo.get_by(
        Teacher,
        id: params["id"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    if teacher.email == nil do
      conn
      |> put_flash(:info, "Please assign teacher email before creating teacher login.")
      |> redirect(to: teacher_path(conn, :index))
    else
      user = Repo.get_by(User, email: teacher.email)

      if user != nil do
        conn
        |> put_flash(:info, "User/Email already exist.")
        |> redirect(to: teacher_path(conn, :index))
      else
        password = teacher.icno
        crypted_password = Comeonin.Bcrypt.hashpwsalt(password)

        user_params = %{
          email: teacher.email,
          name: teacher.name,
          password: teacher.icno,
          crypted_password: crypted_password,
          role: "Teacher",
          is_librarian: false
        }

        case Settings.create_user(user_params) do
          {:ok, user} ->
            Settings.create_user_access(%{
              institution_id: conn.private.plug_session["institution_id"],
              user_id: user.id
            })

            conn
            |> put_flash(:info, "Teacher login succesfully created.")
            |> redirect(to: teacher_path(conn, :index))

          {:error, user} ->
            conn
            |> put_flash(:info, "Having Problem in Creating a Teacher Login.")
            |> redirect(to: teacher_path(conn, :index))
        end
      end
    end
  end

  def edit_teacher_login(conn, params) do
    user = Repo.get_by(User, id: params["id"])

    render(conn, "edit_teacher_login.html", user: user)
  end

  def teacher_timetable(conn, _params) do
    teacher = Affairs.list_teacher()

    render(conn, "teacher_timetable.html", teacher: teacher)
  end

  def login_teacher(conn, params) do
    teacher =
      Repo.all(
        from(
          t in Teacher,
          where:
            t.institution_id == ^conn.private.plug_session["institution_id"] and t.is_delete != 1
        )
      )
      |> Enum.with_index()

    render(conn, "teachers.html", teacher: teacher)
  end

  def teacher_listing(conn, _params) do
    # teacher = Affairs.list_teacher() |> Enum.with_index()
    user_id = conn.private.plug_session["user_id"]
    user = Repo.get(User, user_id)

    teacher =
      Repo.all(
        from(
          s in School.Affairs.Teacher,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and s.is_delete != 1,
          order_by: [asc: s.rank, asc: s.name]
        )
      )
      |> Enum.with_index()

    render(conn, "teacher_listing.html", teacher: teacher)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher(%Teacher{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teacher" => teacher_params}) do
    image_params = teacher_params["image1"]

    teacher_params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        teacher_params = Map.put(teacher_params, "image_bin", result.bin)
        teacher_params = Map.put(teacher_params, "image_filename", result.filename)
      else
        teacher_params
      end

    teacher_params =
      Map.put(teacher_params, "institution_id", conn.private.plug_session["institution_id"])

    tc =
      Repo.get_by(
        Teacher,
        code: teacher_params["code"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    if tc == nil do
      case Affairs.create_teacher(teacher_params) do
        {:ok, teacher} ->
          conn
          |> put_flash(:info, "Teacher created successfully.")
          |> redirect(to: teacher_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:info, "Code Already Exist.")
      |> redirect(to: teacher_path(conn, :new))
    end
  end

  def upload_image(param, conn) do
    {:ok, seconds} = Timex.format(Timex.now(), "%s", :strftime)

    institute = Repo.get(Institution, conn.private.plug_session["institution_id"])

    path = File.cwd!() <> "/media/" <> institute.name
    image_path = Application.app_dir(:school, "priv/static/images")

    if File.exists?(path) == false do
      File.mkdir(File.cwd!() <> "/media/" <> institute.name)
    end

    fl = param.filename |> String.replace(" ", "_")
    absolute_path = path <> "/#{seconds <> fl}"
    absolute_path_bin = path <> "/bin_" <> "#{seconds <> fl}"
    File.cp(param.path, absolute_path)
    File.rm(image_path <> "/uploads")
    File.ln_s(path, image_path <> "/uploads")

    resized = Mogrify.open(absolute_path) |> resize("200x200") |> save(path: absolute_path_bin)
    {:ok, bin} = File.read(resized.path)

    # File.rm(resized.path)

    %{filename: seconds <> fl, bin: Base.encode64(bin)}
  end

  def generate_teacher_image(conn, params) do
    all_params = params["item"]["image1"]

    for image_params <- all_params do
      result = upload_image(image_params, conn)

      params = Map.put(params, "image_bin", result.bin)
      params = Map.put(params, "image_filename", result.filename)

      teacher = image_params

      teacher_name = teacher.filename |> String.split(".") |> hd

      teacher =
        Repo.get_by(
          Teacher,
          name: teacher_name,
          institution_id: conn.private.plug_session["institution_id"]
        )

      if teacher != nil do
        teacher_params = %{image_bin: result.bin, image_filename: result.filename}

        Affairs.update_teacher(teacher, teacher_params)
      else
      end
    end

    conn
    |> put_flash(:info, "Teacher Upload Succesfully")
    |> redirect(to: teacher_path(conn, :index))
  end

  def show(conn, %{"id" => id}) do
    user_id = conn.private.plug_session["user_id"]
    user = Repo.get(User, user_id)

    teacher = Repo.get_by(Teacher, email: user.email)
    changeset = Affairs.change_teacher(teacher)
    teacher = Affairs.get_teacher!(teacher.id)

    render(conn, "edit.html", bin: teacher.image_bin, teacher: teacher, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    teacher = Affairs.get_teacher!(id)
    changeset = Affairs.change_teacher(teacher)

    render(conn, "edit.html", teacher: teacher, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher" => teacher_params}) do
    code = teacher_params["code"]

    teacher =
      Repo.get_by(
        Teacher,
        code: code,
        institution_id: conn.private.plug_session["institution_id"]
      )

    teacher_params =
      if teacher_params["is_delete"] == "true" do
        Map.put(teacher_params, "is_delete", "1")
      else
        teacher_params
      end

    teacher_params =
      if teacher_params["is_delete"] == "false" do
        Map.put(teacher_params, "is_delete", "0")
      else
        teacher_params
      end

    image_params = teacher_params["image1"]

    teacher_params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        Map.put(teacher_params, "image_bin", result.bin)
      else
        teacher_params
      end

    teacher_params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        Map.put(teacher_params, "image_filename", result.filename)
      else
        teacher_params
      end

    if teacher == nil do
      teacher = Repo.get(Teacher, id)
    end

    teacherss = Teacher.changeset(teacher, teacher_params)
    user_result = Repo.all(from(u in User, where: u.email == ^teacher.email))

    case Repo.update(teacherss) do
      {:ok, teacher} ->
        # update the user... 

        if user_result != [] do
          u = hd(user_result)

          res = User.changeset(u, %{email: teacher.email}) |> Repo.update()
        end

        url = teacher_path(conn, :index, focus: teacher.code)
        referer = conn.req_headers |> Enum.filter(fn x -> elem(x, 0) == "referer" end)

        if referer != [] do
          refer = hd(referer)
          url = refer |> elem(1) |> String.split("?") |> List.first()

          conn
          |> put_flash(:info, "#{teacher.name} updated successfully.")
          |> redirect(external: url <> "?focus=#{teacher.code}")
        else
          conn
          |> put_flash(:info, "#{teacher.name} updated successfully.")
          |> redirect(to: url)
        end

      {:error, changeset} ->
        conn
        |> put_flash(:info, "Some details are missing.")
        |> redirect(to: page_path(conn, :dashboard))
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher = Affairs.get_teacher!(id)
    {:ok, _teacher} = Affairs.delete_teacher(teacher)

    conn
    |> put_flash(:info, "Teacher deleted successfully.")
    |> redirect(to: teacher_path(conn, :teacher_setting))
  end

  def pre_upload_teachers(conn, params) do
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

  def upload_teachers(conn, params) do
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

    contents = tl(data)

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

        teachers_params = Enum.zip(h, c) |> Enum.into(%{})

        teachers_params =
          Map.put(teachers_params, "institution_id", conn.private.plug_session["institution_id"])

        cg = Teacher.changeset(%Teacher{}, teachers_params)

        case Repo.insert(cg) do
          {:ok, teacher} ->
            teachers_params
            teachers_params = Map.put(teachers_params, "reason", "ok")

          {:error, changeset} ->
            errors = changeset.errors |> Keyword.keys()

            {reason, message} = changeset.errors |> hd()
            {proper_message, message_list} = message
            final_reason = Atom.to_string(reason) <> " " <> proper_message
            teachers_params = Map.put(teachers_params, "reason", final_reason)

            teachers_params
        end
      end

    header = result |> hd() |> Map.keys()
    body = result |> Enum.map(fn x -> Map.values(x) end)
    new_io = List.insert_at(body, 0, header) |> CSV.encode() |> Enum.to_list() |> to_string
    {:ok, batch} = Settings.update_batch(batch, %{result: new_io})

    conn
    |> put_flash(:info, "Teachers created successfully.")
    |> redirect(to: teacher_path(conn, :index))
  end
end
