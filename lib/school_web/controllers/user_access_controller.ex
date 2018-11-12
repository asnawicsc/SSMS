defmodule SchoolWeb.UserAccessController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.UserAccess
  alias School.Settings.Institution
  require IEx

  def index(conn, _params) do
    user_access = Settings.list_user_access()
    render(conn, "index.html", user_access: user_access)
  end

  def new(conn, _params) do
    changeset = Settings.change_user_access(%UserAccess{})
    render(conn, "new.html", changeset: changeset)
  end

  def user_access_pass(conn, %{"id" => id}) do
    institutions =
      Repo.all(
        from(
          u in Institution,
          select: %{
            id: u.id,
            name: u.name
          }
        )
      )

    selected =
      Repo.all(
        from(
          u in UserAccess,
          left_join: b in Institution,
          on: b.id == u.institution_id,
          where: u.user_id == ^id,
          select: %{
            id: b.id,
            name: b.name
          }
        )
      )

    not_selected = institutions -- selected

    render(conn, "user_access_pass.html", id: id, not_selected: not_selected, selected: selected)
  end

  def create(conn, %{"user_access" => user_access_params}) do
    case Settings.create_user_access(user_access_params) do
      {:ok, user_access} ->
        conn
        |> put_flash(:info, "User access created successfully.")
        |> redirect(to: user_access_path(conn, :show, user_access))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_access = Settings.get_user_access!(id)
    render(conn, "show.html", user_access: user_access)
  end

  def edit(conn, %{"id" => id}) do
    user_access = Settings.get_user_access!(id)
    changeset = Settings.change_user_access(user_access)
    render(conn, "edit.html", user_access: user_access, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_access" => user_access_params}) do
    user_access = Settings.get_user_access!(id)

    case Settings.update_user_access(user_access, user_access_params) do
      {:ok, user_access} ->
        conn
        |> put_flash(:info, "User access updated successfully.")
        |> redirect(to: user_access_path(conn, :show, user_access))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user_access: user_access, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_access = Settings.get_user_access!(id)
    {:ok, _user_access} = Settings.delete_user_access(user_access)

    conn
    |> put_flash(:info, "User access deleted successfully.")
    |> redirect(to: user_access_path(conn, :index))
  end
end
