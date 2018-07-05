defmodule SchoolWeb.AbsentController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Absent

  def index(conn, _params) do
    absent = Affairs.list_absent()
    render(conn, "index.html", absent: absent)
  end

  def new(conn, _params) do
    changeset = Affairs.change_absent(%Absent{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"absent" => absent_params}) do
    case Affairs.create_absent(absent_params) do
      {:ok, absent} ->
        conn
        |> put_flash(:info, "Absent created successfully.")
        |> redirect(to: absent_path(conn, :show, absent))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    absent = Affairs.get_absent!(id)
    render(conn, "show.html", absent: absent)
  end

  def edit(conn, %{"id" => id}) do
    absent = Affairs.get_absent!(id)
    changeset = Affairs.change_absent(absent)
    render(conn, "edit.html", absent: absent, changeset: changeset)
  end

  def update(conn, %{"id" => id, "absent" => absent_params}) do
    absent = Affairs.get_absent!(id)

    case Affairs.update_absent(absent, absent_params) do
      {:ok, absent} ->
        conn
        |> put_flash(:info, "Absent updated successfully.")
        |> redirect(to: absent_path(conn, :show, absent))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", absent: absent, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    absent = Affairs.get_absent!(id)
    {:ok, _absent} = Affairs.delete_absent(absent)

    conn
    |> put_flash(:info, "Absent deleted successfully.")
    |> redirect(to: absent_path(conn, :index))
  end
end
