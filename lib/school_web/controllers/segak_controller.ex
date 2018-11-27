defmodule SchoolWeb.SegakController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.Segak

  def index(conn, _params) do
    segak = Affairs.list_segak()
    render(conn, "index.html", segak: segak)
  end

  def create_segak(conn, _params) do
    segak = Affairs.list_segak()

    classes =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    semesters = Affairs.get_inst_id(conn) |> Affairs.list_semesters()

    render(conn, "create_segak_mark.html", segak: segak, semesters: semesters, classes: classes)
  end

  def segak_mark(conn, params) do
    class =
      Repo.get_by(Class,
        id: params["class_id"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    semester_id = params["semester_id"]
    class_id = params["class_id"]

    students =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: t in School.Affairs.Student,
          on: t.id == s.sudent_id,
          where:
            s.institute_id == ^School.Affairs.inst_id(conn) and
              s.semester_id == ^params["semester_id"] and s.class_id == ^params["class_id"],
          select: %{
            chinese_name: t.chinese_name,
            name: t.name,
            id: t.id,
            ic: t.ic,
            student_no: t.student_no,
            phone: t.phone
          }
        )
      )

    segak =
      Repo.all(
        from(s in School.Affairs.Segak,
          left_join: g in School.Affairs.Student,
          on: g.id == s.student_id,
          where:
            s.semester_id == ^semester_id and s.class_id == ^class_id and
              s.standard_id == ^class.level_id and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              g.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{id: s.student_id, name: g.name, mark: s.mark}
        )
      )

    if segak != [] do
      render(conn, "edit_segak_mark.html",
        segak: segak,
        class: class,
        semester_id: semester_id,
        class_id: class_id,
        standard_id: class.level_id
      )
    else
      render(conn, "segak_mark.html",
        students: students,
        class: class,
        semester_id: semester_id,
        class_id: class_id,
        standard_id: class.level_id
      )
    end
  end

  def create_segak_mark(conn, params) do
    class_id = params["class_id"]
    mark = params["mark"]
    semester_id = params["semester_id"]
    standard_id = params["standard_id"]

    for item <- mark do
      student_id = item |> elem(0)
      mark = item |> elem(1)

      segak_mark_params = %{
        class_id: class_id,
        semester_id: semester_id,
        mark: mark,
        standard_id: standard_id,
        student_id: student_id,
        institution_id: conn.private.plug_session["institution_id"]
      }

      Affairs.create_segak(segak_mark_params)
    end

    conn
    |> put_flash(:info, "Segak mark created successfully.")
    |> redirect(to: segak_path(conn, :create_segak))
  end

  def edit_segak_mark(conn, params) do
    class_id = params["class_id"]
    mark = params["mark"]
    semester_id = params["semester_id"]
    standard_id = params["standard_id"]

    for item <- mark do
      student_id = item |> elem(0)
      mark = item |> elem(1)

      segak_mark_params = %{
        class_id: class_id,
        semester_id: semester_id,
        mark: mark,
        standard_id: standard_id,
        student_id: student_id,
        institution_id: conn.private.plug_session["institution_id"]
      }

      segak =
        Repo.get_by(School.Affairs.Segak,
          class_id: class_id,
          semester_id: semester_id,
          standard_id: standard_id,
          student_id: student_id,
          institution_id: conn.private.plug_session["institution_id"]
        )

      Affairs.update_segak(segak, segak_mark_params)
    end

    conn
    |> put_flash(:info, "Segak mark updated successfully.")
    |> redirect(to: segak_path(conn, :create_segak))
  end

  def new(conn, _params) do
    changeset = Affairs.change_segak(%Segak{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"segak" => segak_params}) do
    case Affairs.create_segak(segak_params) do
      {:ok, segak} ->
        conn
        |> put_flash(:info, "Segak created successfully.")
        |> redirect(to: segak_path(conn, :show, segak))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    segak = Affairs.get_segak!(id)
    render(conn, "show.html", segak: segak)
  end

  def edit(conn, %{"id" => id}) do
    segak = Affairs.get_segak!(id)
    changeset = Affairs.change_segak(segak)
    render(conn, "edit.html", segak: segak, changeset: changeset)
  end

  def update(conn, %{"id" => id, "segak" => segak_params}) do
    segak = Affairs.get_segak!(id)

    case Affairs.update_segak(segak, segak_params) do
      {:ok, segak} ->
        conn
        |> put_flash(:info, "Segak updated successfully.")
        |> redirect(to: segak_path(conn, :show, segak))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", segak: segak, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    segak = Affairs.get_segak!(id)
    {:ok, _segak} = Affairs.delete_segak(segak)

    conn
    |> put_flash(:info, "Segak deleted successfully.")
    |> redirect(to: segak_path(conn, :index))
  end
end
