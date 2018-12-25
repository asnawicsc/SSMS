defmodule SchoolWeb.EdisciplineController do
  use SchoolWeb, :controller
  require IEx
  alias School.Affairs
  alias School.Affairs.Ediscipline

  def update_summary(conn, params) do
    ediscipline = Repo.get(Ediscipline, params["edsp_id"])

    case Affairs.update_ediscipline(ediscipline, params) do
      {:ok, ediscipline} ->
        conn
        |> put_flash(:info, "Follow up summary updated successfully.")
        |> redirect(to: teacher_path(conn, :e_discipline))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", ediscipline: ediscipline, changeset: changeset)
    end
  end

  def show_message_details(conn, params) do
    edsp = Repo.get(Ediscipline, params["msg_id"])
    parent = Repo.get_by(Parent, psid: edsp.psid)

    if Repo.get_by(Student, micno: parent.icno) == nil do
      if Repo.get_by(Student, ficno: parent.icno) == nil do
        if Repo.get_by(Student, gicno: parent.icno) != nil do
          student = Repo.get_by(Student, gicno: parent.icno)
        end
      else
        student = Repo.get_by(Student, ficno: parent.icno)
      end
    else
      student = Repo.get_by(Student, micno: parent.icno)
    end

    render(conn, "message_details.html", student: student, parent: parent, edsp: edsp)
  end

  def ediscipline_form(conn, params) do
    user = Repo.get(User, conn.private.plug_session["user_id"])

    if user.role == "Teacher" do
      teacher = Repo.get_by(Teacher, email: user.email)
    end

    all_students =
      Repo.all(
        from(
          s in Student,
          left_join: sc in StudentClass,
          on: sc.sudent_id == s.id,
          left_join: c in Class,
          on: c.id == sc.class_id,
          left_join: t in Teacher,
          on: t.id == c.teacher_id,
          where:
            t.id == ^teacher.id and sc.semester_id == ^conn.private.plug_session["semester_id"]
        )
      )

    render(conn, "ed_form.html", all_students: all_students)
  end

  def msg_details(conn, params) do
    parent = Repo.get(Parent, params["parent_id"])
    user = Repo.get(User, conn.private.plug_session["user_id"])
    teacher = Repo.get_by(Teacher, email: user.email)
    params = Map.put(params, "teacher_id", teacher.id)
    params = Map.put(params, "psid", parent.psid)

    case Affairs.create_ediscipline(params) do
      {:ok, ediscipline} ->
        SchoolWeb.ApiController.edcp_inform_parent("ed_inform_parent", ediscipline)

        conn
        |> put_flash(:info, "Message Sent !")
        |> redirect(to: ediscipline_path(conn, :ediscipline_form))

      {:error, %Ecto.Changeset{} = changeset} ->
        key = changeset.errors |> hd() |> elem(0) |> to_string()
        value = changeset.errors |> hd() |> elem(1) |> elem(0)
        err_message = key <> " " <> value

        conn
        |> put_flash(:info, err_message)
        |> redirect(to: ediscipline_path(conn, :ediscipline_form))
    end
  end

  def index(conn, _params) do
    edisciplines = Affairs.list_edisciplines()
    render(conn, "index.html", edisciplines: edisciplines)
  end

  def new(conn, _params) do
    changeset = Affairs.change_ediscipline(%Ediscipline{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"ediscipline" => ediscipline_params}) do
    case Affairs.create_ediscipline(ediscipline_params) do
      {:ok, ediscipline} ->
        conn
        |> put_flash(:info, "Ediscipline created successfully.")
        |> redirect(to: ediscipline_path(conn, :show, ediscipline))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ediscipline = Affairs.get_ediscipline!(id)
    render(conn, "show.html", ediscipline: ediscipline)
  end

  def edit(conn, %{"id" => id}) do
    ediscipline = Affairs.get_ediscipline!(id)
    changeset = Affairs.change_ediscipline(ediscipline)
    render(conn, "edit.html", ediscipline: ediscipline, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ediscipline" => ediscipline_params}) do
    ediscipline = Affairs.get_ediscipline!(id)

    case Affairs.update_ediscipline(ediscipline, ediscipline_params) do
      {:ok, ediscipline} ->
        conn
        |> put_flash(:info, "Ediscipline updated successfully.")
        |> redirect(to: ediscipline_path(conn, :show, ediscipline))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", ediscipline: ediscipline, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ediscipline = Affairs.get_ediscipline!(id)
    {:ok, _ediscipline} = Affairs.delete_ediscipline(ediscipline)

    conn
    |> put_flash(:info, "Ediscipline deleted successfully.")
    |> redirect(to: ediscipline_path(conn, :index))
  end
end
