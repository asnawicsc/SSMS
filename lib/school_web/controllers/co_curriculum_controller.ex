defmodule SchoolWeb.CoCurriculumController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.CoCurriculum
  require IEx

  def index(conn, _params) do
    cocurriculum =
      Affairs.list_cocurriculum()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", cocurriculum: cocurriculum)
  end

  def new(conn, _params) do
    changeset = Affairs.change_co_curriculum(%CoCurriculum{})
    render(conn, "new.html", changeset: changeset)
  end

  def student_report_by_cocurriculum(conn, params) do
    cocurriculum =
      Repo.all(
        from(
          c in CoCurriculum,
          where: c.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    cocurriculum =
      Affairs.list_cocurriculum()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "student_report_by_cocurriculum.html", cocurriculum: cocurriculum)
  end

  def create_student_co(conn, params) do
    cocurriculum_id = params["cocurriculum"]
    standard_id = params["level"]
    subjects = params["student"] |> String.split(",")

    semester_id = params["semester"]
    year = params["year"]

    for subject <- subjects do
      subject_id = subject |> String.to_integer()

      params = %{
        cocurriculum_id: cocurriculum_id,
        standard_id: standard_id,
        student_id: subject_id,
        semester_id: semester_id,
        year: year
      }

      Affairs.create_student_cocurriculum(params)
    end

    conn
    |> put_flash(:info, "Student cocurriculum created successfully.")
    |> redirect(to: co_curriculum_path(conn, :co_curriculum_setting))
  end

  def create_co_mark(conn, params) do
    marks = params["mark"]

    for mark <- marks do
      student_id = mark |> elem(0)
      co_mark = mark |> elem(1)

      semester_id = params["semester_id"]
      standard_id = params["standard_id"]
      year = params["year"]
      cocurriculum_id = params["cocurriculum_id"]

      id =
        Repo.get_by(School.Affairs.StudentCocurriculum, %{
          cocurriculum_id: cocurriculum_id,
          student_id: student_id
        })

      params = %{
        cocurriculum_id: cocurriculum_id,
        standard_id: standard_id,
        student_id: student_id,
        semester_id: semester_id,
        year: year,
        mark: co_mark
      }

      Affairs.update_student_cocurriculum(id, params)
    end

    conn
    |> put_flash(:info, "Student cocurriculum mark created successfully.")
    |> redirect(to: co_curriculum_path(conn, :co_mark))
  end

  def edit_co_mark(conn, params) do
    marks = params["mark"]

    for mark <- marks do
      student_id = mark |> elem(0)
      co_mark = mark |> elem(1)

      semester_id = params["semester_id"]
      standard_id = params["standard_id"]
      year = params["year"]
      cocurriculum_id = params["cocurriculum_id"]

      id =
        Repo.get_by(School.Affairs.StudentCocurriculum, %{
          cocurriculum_id: cocurriculum_id,
          student_id: student_id
        })

      params = %{
        cocurriculum_id: cocurriculum_id,
        standard_id: standard_id,
        student_id: student_id,
        semester_id: semester_id,
        year: year,
        mark: co_mark
      }

      Affairs.update_student_cocurriculum(id, params)
    end

    conn
    |> put_flash(:info, "Student cocurriculum mark updated successfully.")
    |> redirect(to: co_curriculum_path(conn, :co_mark))
  end

  def co_mark(conn, params) do
    user = Repo.get_by(School.Settings.User, %{id: conn.private.plug_session["user_id"]})
    teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})

    cocurriculum =
      if user.role == "Admin" or user.role == "Support" do
        Affairs.list_cocurriculum()
      else
        Affairs.list_cocurriculum()
        |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
        |> Enum.filter(fn x -> x.teacher_id == teacher.id end)
      end

    if cocurriculum == [] do
      conn
      |> put_flash(:info, "You Are Not Assign to Any CoCurriculum Class")
      |> redirect(to: page_path(conn, :dashboard))
    else
      render(conn, "co_mark.html", cocurriculum: cocurriculum)
    end
  end

  def marking(conn, params) do
    cocurriculum = params["id"]

    co = Repo.get_by(School.Affairs.CoCurriculum, %{id: cocurriculum})

    students =
      Repo.all(
        from(
          s in School.Affairs.StudentCocurriculum,
          left_join: a in School.Affairs.Student,
          on: s.student_id == a.id,
          left_join: j in School.Affairs.StudentClass,
          on: s.student_id == j.sudent_id,
          left_join: p in School.Affairs.CoCurriculum,
          on: s.cocurriculum_id == p.id,
          left_join: c in School.Affairs.Class,
          on: j.class_id == c.id,
          where:
            s.cocurriculum_id == ^cocurriculum and
              a.institution_id == ^conn.private.plug_session["institution_id"] and
              c.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            id: p.id,
            student_id: s.student_id,
            name: a.name,
            class_name: c.name,
            mark: s.mark
          }
        )
      )

    condition = students |> Enum.map(fn x -> x.mark end) |> Enum.filter(fn x -> x != nil end)

    if condition == [] do
      render(
        conn,
        "assign_mark.html",
        students: students,
        co: co
      )
    else
      render(
        conn,
        "edit_mark.html",
        students: students,
        co: co
      )
    end
  end

  def co_curriculum_setting(conn, _params) do
    level =
      Repo.all(
        from(
          s in School.Affairs.Level,
          select: %{institution_id: s.institution_id, id: s.id, name: s.name}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    semester =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          select: %{institution_id: s.institution_id, id: s.id, start_date: s.start_date}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    students =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: a in School.Affairs.Student,
          on: s.sudent_id == a.id,
          left_join: c in School.Affairs.Class,
          on: s.class_id == c.id,
          left_join: m in School.Affairs.StudentCocurriculum,
          on: s.sudent_id != m.id,
          where:
            a.institution_id == ^conn.private.plug_session["institution_id"] and
              c.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{id: a.id, name: a.name, class_name: c.name}
        )
      )
      |> Enum.uniq()

    students_co =
      Repo.all(
        from(
          s in School.Affairs.StudentCocurriculum,
          left_join: sc in School.Affairs.StudentClass,
          on: s.student_id == sc.sudent_id,
          left_join: a in School.Affairs.Student,
          on: s.student_id == a.id,
          left_join: c in School.Affairs.Class,
          on: sc.class_id == c.id,
          where: a.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{id: a.id, name: a.name, class_name: c.name}
        )
      )

    students = students -- students_co

    cocurriculum =
      Affairs.list_cocurriculum()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    changeset = Affairs.change_co_curriculum(%CoCurriculum{})

    render(
      conn,
      "co_curriculum_setting.html",
      semester: semester,
      students: students,
      level: level,
      cocurriculum: cocurriculum,
      changeset: changeset
    )
  end

  def create(conn, %{"co_curriculum" => co_curriculum_params}) do
    co_curriculum_params =
      Map.put(co_curriculum_params, "institution_id", conn.private.plug_session["institution_id"])

    case Affairs.create_co_curriculum(co_curriculum_params) do
      {:ok, co_curriculum} ->
        conn
        |> put_flash(:info, "Co curriculum created successfully.")
        |> redirect(to: co_curriculum_path(conn, :co_curriculum_setting))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    co_curriculum = Affairs.get_co_curriculum!(id)
    render(conn, "show.html", co_curriculum: co_curriculum)
  end

  def edit(conn, %{"id" => id}) do
    co_curriculum = Affairs.get_co_curriculum!(id)
    changeset = Affairs.change_co_curriculum(co_curriculum)
    render(conn, "edit.html", co_curriculum: co_curriculum, changeset: changeset)
  end

  def update(conn, %{"id" => id, "co_curriculum" => co_curriculum_params}) do
    co_curriculum = Affairs.get_co_curriculum!(id)

    case Affairs.update_co_curriculum(co_curriculum, co_curriculum_params) do
      {:ok, co_curriculum} ->
        conn
        |> put_flash(:info, "Co curriculum updated successfully.")
        |> redirect(to: co_curriculum_path(conn, :show, co_curriculum))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", co_curriculum: co_curriculum, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    co_curriculum = Affairs.get_co_curriculum!(id)
    {:ok, _co_curriculum} = Affairs.delete_co_curriculum(co_curriculum)

    conn
    |> put_flash(:info, "Co curriculum deleted successfully.")
    |> redirect(to: co_curriculum_path(conn, :index))
  end
end
