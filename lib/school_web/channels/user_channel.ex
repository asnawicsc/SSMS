defmodule SchoolWeb.UserChannel do
  use SchoolWeb, :channel
require IEx
alias School.Affairs
  def join("user:"<>user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
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
    csrf = Phoenix.Controller.get_csrf_token
    broadcast socket, "show_student_details", %{html: html, csrf: csrf}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
