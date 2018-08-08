defmodule SchoolWeb.UserChannel do
  use SchoolWeb, :channel
  require IEx
  alias School.Affairs
  alias School.Affairs.Subject
   alias School.Affairs.Teacher
   alias School.Affairs.Parent

  def join("user:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("load_footer", payload, socket) do
    id = payload["inst_id"]
    inst = Repo.get(School.Settings.Institution, id)

    broadcast(socket, "show_footer", %{logo_bin: inst.logo_bin, maintain: inst.maintained_by})
    {:noreply, socket}
  end

  def handle_in("load_absent_reasons", payload, socket) do
    absent =
      Repo.all(
        from(
          a in Absent,
          where: a.absent_date == ^Date.utc_today() and a.student_id == ^payload["student_id"]
        )
      )

    if absent != [] do
      broadcast(socket, "show_reasons", %{
        student_id: hd(absent).student_id,
        reason: hd(absent).reason
      })
    end

    {:noreply, socket}
  end

  def handle_in("inquire_student_details", payload, socket) do
    id = payload["student_id"]
    user = Repo.get(School.Settings.User, payload["user_id"])
    student = Affairs.get_student!(id)
    changeset = Affairs.change_student(student)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.StudentView,
        "form.html",
        student: student,
        changeset: changeset,
        conn: conn,
        action: "/students/#{student.id}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_student_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_subject_details", payload, socket) do
    code = payload["code"]|>String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    subject = Repo.get_by(Subject,code: code)
    changeset = Affairs.change_subject(subject)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.SubjectView,
        "form.html",
        code: code,
        changeset: changeset,
        conn: conn,
        action: "/subject/#{subject.code}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_subject_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_teacher_details", payload, socket) do
    code = payload["code"]|>String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    teacher = Repo.get_by(Teacher,code: code)
    changeset = Affairs.change_teacher(teacher)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.TeacherView,
        "form.html",
        code: code,
        changeset: changeset,
        conn: conn,
        action: "/teacher/#{teacher.code}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_teacher_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

   def handle_in("inquire_parent_details", payload, socket) do
    icno = payload["icno"]|>String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    parent = Repo.get_by(Parent,icno: icno)

    changeset = Affairs.change_parent(parent)



    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ParentView,
        "form.html",
        icno: icno,
        changeset: changeset,
        conn: conn,
        action: "/parent/#{parent.icno}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_parent_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
