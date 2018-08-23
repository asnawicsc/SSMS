defmodule SchoolWeb.AbsentReasonController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.AbsentReason

  def index(conn, _params) do
    absent_reason = Affairs.list_absent_reason()
    render(conn, "index.html", absent_reason: absent_reason)
  end

  def new(conn, _params) do
    changeset = Affairs.change_absent_reason(%AbsentReason{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"absent_reason" => absent_reason_params}) do
    case Affairs.create_absent_reason(absent_reason_params) do
      {:ok, absent_reason} ->
        conn
        |> put_flash(:info, "Absent reason created successfully.")
       |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    absent_reason = Affairs.get_absent_reason!(id)
    render(conn, "show.html", absent_reason: absent_reason)
  end

  def edit(conn, %{"id" => id}) do
    absent_reason = Affairs.get_absent_reason!(id)
    changeset = Affairs.change_absent_reason(absent_reason)
    render(conn, "edit.html", absent_reason: absent_reason, changeset: changeset)
  end

  def update(conn, %{"id" => id, "absent_reason" => absent_reason_params}) do
    absent_reason = Affairs.get_absent_reason!(id)

    case Affairs.update_absent_reason(absent_reason, absent_reason_params) do
      {:ok, absent_reason} ->
        conn
        |> put_flash(:info, "Absent reason updated successfully.")
          |> redirect(to: teacher_path(conn, :teacher_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", absent_reason: absent_reason, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    absent_reason = Affairs.get_absent_reason!(id)
    {:ok, _absent_reason} = Affairs.delete_absent_reason(absent_reason)

    conn
    |> put_flash(:info, "Absent reason deleted successfully.")
     |> redirect(to: teacher_path(conn, :teacher_setting))
  end
end
