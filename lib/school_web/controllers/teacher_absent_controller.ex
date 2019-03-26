defmodule SchoolWeb.TeacherAbsentController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TeacherAbsent
  require IEx

  def index(conn, _params) do
    teacher_absent = Affairs.list_teacher_absent()
    render(conn, "index.html", teacher_absent: teacher_absent)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher_absent(%TeacherAbsent{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teacher_absent" => teacher_absent_params}) do
    case Affairs.create_teacher_absent(teacher_absent_params) do
      {:ok, teacher_absent} ->
        conn
        |> put_flash(:info, "Teacher absent created successfully.")
        |> redirect(to: teacher_absent_path(conn, :show, teacher_absent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create_teacher_absent_leave(conn, params) do
    teacher_absent_reason =
      Repo.all(
        from(s in School.Affairs.TeacherAbsentReason,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: s.absent_reason
        )
      )

    teacher =
      Repo.all(
        from(
          t in Teacher,
          select: %{id: t.id, name: t.name},
          where:
            t.institution_id == ^conn.private.plug_session["institution_id"] and t.is_delete != 1
        )
      )

    render(conn, "create_teacher_absent_leave.html",
      teacher: teacher,
      teacher_absent_reason: teacher_absent_reason
    )
  end

  def create_teacher_leave(conn, params) do
    alasan = params["alasan"]
    teacher_id = params["teacher_id"]
    start_date = params["start_date"] |> Date.from_iso8601!()
    end_date = params["end_date"] |> Date.from_iso8601!()

    lists = Date.range(start_date, end_date) |> Enum.map(fn x -> x end)

    for item <- lists do
      teacher_absent_params = %{
        alasan: alasan,
        date: item,
        institution_id: conn.private.plug_session["institution_id"],
        semester_id: conn.private.plug_session["semester_id"],
        remark: "CUTI DENGAN ALASAN",
        teacher_id: teacher_id,
        month: item.month |> Integer.to_string()
      }

      Affairs.create_teacher_absent(teacher_absent_params)
    end

    conn
    |> put_flash(:info, "Teacher absent created successfully.")
    |> redirect(to: teacher_absent_path(conn, :index))
  end

  def show(conn, %{"id" => id}) do
    teacher_absent = Affairs.get_teacher_absent!(id)
    render(conn, "show.html", teacher_absent: teacher_absent)
  end

  def edit(conn, %{"id" => id}) do
    teacher_absent = Affairs.get_teacher_absent!(id)
    changeset = Affairs.change_teacher_absent(teacher_absent)
    render(conn, "edit.html", teacher_absent: teacher_absent, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher_absent" => teacher_absent_params}) do
    teacher_absent = Affairs.get_teacher_absent!(id)

    case Affairs.update_teacher_absent(teacher_absent, teacher_absent_params) do
      {:ok, teacher_absent} ->
        conn
        |> put_flash(:info, "Teacher absent updated successfully.")
        |> redirect(to: teacher_absent_path(conn, :show, teacher_absent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_absent: teacher_absent, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_absent = Affairs.get_teacher_absent!(id)
    {:ok, _teacher_absent} = Affairs.delete_teacher_absent(teacher_absent)

    conn
    |> put_flash(:info, "Teacher absent deleted successfully.")
    |> redirect(to: teacher_absent_path(conn, :index))
  end
end
