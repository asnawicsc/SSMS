defmodule SchoolWeb.RoleController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.Role

  def index(conn, _params) do
    role = Settings.list_role()
    render(conn, "index.html", role: role)
  end

  def new(conn, _params) do
    changeset = Settings.change_role(%Role{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"role" => role_params}) do
    case Settings.create_role(role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role created successfully.")
        |> redirect(to: role_path(conn, :show, role))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Settings.get_role!(id)
    render(conn, "show.html", role: role)
  end

  def edit(conn, %{"id" => id}) do
    role = Settings.get_role!(id)
    changeset = Settings.change_role(role)
    render(conn, "edit.html", role: role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Settings.get_role!(id)

    case Settings.update_role(role, role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: role_path(conn, :show, role))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", role: role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Settings.get_role!(id)
    {:ok, _role} = Settings.delete_role(role)

    conn
    |> put_flash(:info, "Role deleted successfully.")
    |> redirect(to: role_path(conn, :index))
  end
end
