defmodule SchoolWeb.TeacherController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Teacher
  alias School.Settings.User
  alias School.Settings.UserAccess
  require IEx

  def index(conn, _params) do
    teacher =
      Affairs.list_teacher()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", teacher: teacher)
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

  def teacher_timetable(conn, _params) do
    teacher = Affairs.list_teacher()

    render(conn, "teacher_timetable.html", teacher: teacher)
  end

  def login_teacher(conn, params) do
    teacher =
      Repo.all(
        from(
          t in Teacher,
          where: t.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )
      |> Enum.with_index()

    render(conn, "teachers.html", teacher: teacher)
  end

  def teacher_listing(conn, _params) do
    # teacher = Affairs.list_teacher() |> Enum.with_index()
    user_id = conn.private.plug_session["user_id"]
    user = Repo.get(User, user_id)

    if user.role == "Teacher" do
      teacher = Repo.get_by(Teacher, email: user.email)
      changeset = Affairs.change_teacher(teacher)
      action = "/teacher/#{teacher.code}"
      render(conn, "form.html", changeset: changeset, action: action)
    end

    if user.role == "Support" or user.role == "Admin" do
      teacher =
        Repo.all(
          from(
            t in Teacher,
            where: t.institution_id == ^conn.private.plug_session["institution_id"]
          )
        )
        |> Enum.with_index()

      render(conn, "teacher_listing.html", teacher: teacher)
    end
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher(%Teacher{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teacher" => teacher_params}) do
    teacher_params =
      Map.put(teacher_params, "institution_id", conn.private.plug_session["institution_id"])

    case Affairs.create_teacher(teacher_params) do
      {:ok, teacher} ->
        conn
        |> put_flash(:info, "Teacher created successfully.")
        |> redirect(to: teacher_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher = Affairs.get_teacher!(id)
    render(conn, "show.html", teacher: teacher)
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

    case Affairs.update_teacher(teacher, teacher_params) do
      {:ok, teacher} ->
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
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher = Affairs.get_teacher!(id)
    {:ok, _teacher} = Affairs.delete_teacher(teacher)

    conn
    |> put_flash(:info, "Teacher deleted successfully.")
    |> redirect(to: teacher_path(conn, :teacher_setting))
  end

  def upload_teachers(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    data = bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)
    contents = tl(data)

    teachers_params =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

        c =
          for item <- content do
            item = String.replace(item, "@@@", ",")

            case item do
              {:ok, i} ->
                i

              _ ->
                cond do
                  item == " " ->
                    "null"

                  item == "" ->
                    "null"

                  item == "  " ->
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

        if is_integer(teachers_params["bcenrlno"]) do
          teachers_params =
            Map.put(teachers_params, "bcenrlno", Integer.to_string(teachers_params["bcenrlno"]))
        end

        teachers_params =
          Map.put(teachers_params, "institution_id", conn.private.plug_session["institution_id"])

        cg = Teacher.changeset(%Teacher{}, teachers_params)

        case Repo.insert(cg) do
          {:ok, teacher} ->
            {:ok, teacher}

          {:error, cg} ->
            {:error, cg}
        end
      end

    conn
    |> put_flash(:info, "Teachers created successfully.")
    |> redirect(to: teacher_path(conn, :teacher_setting))
  end
end
