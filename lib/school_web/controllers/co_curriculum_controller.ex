defmodule SchoolWeb.CoCurriculumController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.CoCurriculum
  require IEx

  def enroll_students(conn, params) do
    inst_id = Affairs.get_inst_id(conn)
    cocos = Affairs.list_cocurriculum(Affairs.get_inst_id(conn))
    semesters = Affairs.list_semesters(inst_id)
    render(conn, "enroll_students.html", cocos: cocos, semesters: semesters)
  end

  def index(conn, _params) do
    cocurriculum = Affairs.list_cocurriculum(Affairs.get_inst_id(conn))

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
    |> redirect(to: co_curriculum_path(conn, :cocurriculum))
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
          student_id: student_id,
          semester_id: semester_id
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
          student_id: student_id,
          semester_id: semester_id
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

    semesters = Affairs.get_inst_id(conn) |> Affairs.list_semesters()

    cocurriculum =
      if user.role == "Admin" or user.role == "Support" do
        Affairs.list_cocurriculum()

        Repo.all(
          from(
            c in CoCurriculum,
            left_join: t in Teacher,
            on: t.id == c.teacher_id,
            where: c.institution_id == ^conn.private.plug_session["institution_id"],
            select: %{
              id: c.id,
              code: c.code,
              description: c.description,
              institution_id: c.institution_id,
              teacher_name: t.name,
              teacher_id: c.teacher_id
            }
          )
        )
      else
        Repo.all(
          from(
            c in CoCurriculum,
            left_join: t in Teacher,
            on: t.id == c.teacher_id,
            where: c.institution_id == ^conn.private.plug_session["institution_id"],
            select: %{
              id: c.id,
              code: c.code,
              description: c.description,
              institution_id: c.institution_id,
              teacher_name: t.name,
              teacher_id: c.teacher_id
            }
          )
        )
        |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
        |> Enum.filter(fn x -> x.teacher_id == teacher.id end)
      end

    if cocurriculum == [] do
      conn
      |> put_flash(:info, "You Are Not Assign to Any CoCurriculum Class")
      |> redirect(to: page_path(conn, :dashboard))
    else
      render(conn, "co_mark.html", cocurriculum: cocurriculum, semesters: semesters)
    end
  end

  def marking(conn, params) do
    cocurriculum = params["id"]
    sem = Repo.get(Semester, params["semester_id"])
    co = Repo.get_by(School.Affairs.CoCurriculum, %{id: cocurriculum})
    inst_id = conn.private.plug_session["institution_id"]

    students =
      Repo.all(
        from(
          sc in School.Affairs.StudentCocurriculum,
          left_join: s in School.Affairs.Student,
          on: sc.student_id == s.id,
          left_join: c in School.Affairs.CoCurriculum,
          on: sc.cocurriculum_id == c.id,
          where:
            sc.cocurriculum_id == ^cocurriculum and s.institution_id == ^inst_id and
              c.institution_id == ^inst_id and sc.semester_id == ^params["semester_id"],
          select: %{
            student_id: sc.student_id,
            mark: sc.mark,
            sc_id: sc.id,
            name: s.name
          }
        )
      )

    if students == [] do
      conn
      |> put_flash(:info, "Not Student in this CoCurriculum.")
      |> redirect(to: co_curriculum_path(conn, :co_mark))
    else
      sc =
        Repo.all(
          from(
            s in Student,
            left_join: sc in StudentClass,
            on: sc.sudent_id == s.id,
            left_join: c in Class,
            on: c.id == sc.class_id,
            where: sc.institute_id == ^inst_id and sc.semester_id == ^params["semester_id"],
            select: %{
              student_id: s.id,
              class: c.name
            }
          )
        )

      students =
        for student <- students do
          if Enum.any?(sc, fn x -> x.student_id == student.student_id end) do
            b = sc |> Enum.filter(fn x -> x.student_id == student.student_id end) |> hd()

            Map.put(student, :class_name, b.class)
          else
            Map.put(student, :class_name, "no class assigned")
          end
        end

      condition = students |> Enum.map(fn x -> x.mark end) |> Enum.filter(fn x -> x != nil end)

      if condition == [] do
        render(
          conn,
          "assign_mark.html",
          students: students,
          co: co,
          sem: sem
        )
      else
        render(
          conn,
          "edit_mark.html",
          students: students,
          co: co,
          sem: sem
        )
      end
    end
  end

  def edit_co_rank(conn, params) do
    cocurriculum = params["id"]
    sem = Repo.get(Semester, params["semester_id"])
    co = Repo.get_by(School.Affairs.CoCurriculum, %{id: cocurriculum})
    inst_id = conn.private.plug_session["institution_id"]

    students =
      Repo.all(
        from(
          sc in School.Affairs.StudentCocurriculum,
          left_join: s in School.Affairs.Student,
          on: sc.student_id == s.id,
          left_join: c in School.Affairs.CoCurriculum,
          on: sc.cocurriculum_id == c.id,
          where:
            sc.cocurriculum_id == ^cocurriculum and s.institution_id == ^inst_id and
              c.institution_id == ^inst_id and sc.semester_id == ^params["semester_id"],
          select: %{
            student_id: sc.student_id,
            mark: sc.mark,
            sc_id: sc.id,
            name: s.name,
            rank: sc.rank
          }
        )
      )

    if students == [] do
      conn
      |> put_flash(:info, "Not Student in this CoCurriculum.")
      |> redirect(to: co_curriculum_path(conn, :co_mark))
    else
      sc =
        Repo.all(
          from(
            s in Student,
            left_join: sc in StudentClass,
            on: sc.sudent_id == s.id,
            left_join: c in Class,
            on: c.id == sc.class_id,
            where: sc.institute_id == ^inst_id and sc.semester_id == ^params["semester_id"],
            select: %{
              student_id: s.id,
              class: c.name
            }
          )
        )

      students =
        for student <- students do
          if Enum.any?(sc, fn x -> x.student_id == student.student_id end) do
            b = sc |> Enum.filter(fn x -> x.student_id == student.student_id end) |> hd()

            Map.put(student, :class_name, b.class)
          else
            Map.put(student, :class_name, "no class assigned")
          end
        end

      condition = students |> Enum.map(fn x -> x.rank end) |> Enum.filter(fn x -> x != nil end)

      list_rank =
        Affairs.list_list_rank()
        |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

      if condition == [] do
        render(
          conn,
          "assign_rank.html",
          students: students,
          co: co,
          list_rank: list_rank,
          sem: sem
        )
      else
        render(
          conn,
          "edit_rank.html",
          students: students,
          list_rank: list_rank,
          co: co,
          sem: sem
        )
      end
    end
  end

  def create_rank_student_co(conn, params) do
    ranks = params["rank"]

    for rank <- ranks do
      student_id = rank |> elem(0)
      rank = rank |> elem(1)

      semester_id = params["semester_id"]
      cocurriculum_id = params["cocurriculum_id"]

      id =
        Repo.get_by(School.Affairs.StudentCocurriculum, %{
          cocurriculum_id: cocurriculum_id,
          student_id: student_id,
          semester_id: semester_id
        })

      params = %{rank: rank}

      Affairs.update_student_cocurriculum(id, params)
    end

    conn
    |> put_flash(:info, "Rank updated successfully.")
    |> redirect(to: co_curriculum_path(conn, :co_mark))
  end

  def edit_rank_student_co(conn, params) do
    ranks = params["rank"]

    for rank <- ranks do
      student_id = rank |> elem(0)
      rank = rank |> elem(1)

      semester_id = params["semester_id"]
      cocurriculum_id = params["cocurriculum_id"]

      id =
        Repo.get_by(School.Affairs.StudentCocurriculum, %{
          cocurriculum_id: cocurriculum_id,
          student_id: student_id,
          semester_id: semester_id
        })

      params = %{rank: rank}

      Affairs.update_student_cocurriculum(id, params)
    end

    conn
    |> put_flash(:info, "Rank updated successfully.")
    |> redirect(to: co_curriculum_path(conn, :co_mark))
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
