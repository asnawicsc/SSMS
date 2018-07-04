defmodule SchoolWeb.InstitutionController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.{Institution, User}
  require IEx

  def select(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    user = Settings.current_user(conn)
    User.changeset(user, %{institution_id: id}) |> Repo.update!

    conn
    |> put_session(:institution_id, id)
    |> put_flash(:info, "#{institution.name} selected!")
    |> redirect(to: institution_path(conn, :index))

  end

  def index(conn, _params) do

    institutions = Settings.list_institutions()
    render(conn, "index.html", institutions: institutions)
  end

  def new(conn, _params) do
    changeset = Settings.change_institution(%Institution{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"institution" => institution_params}) do
    case Settings.create_institution(institution_params) do
      {:ok, institution} ->
        conn
        |> put_flash(:info, "Institution created successfully.")
        |> redirect(to: institution_path(conn, :show, institution))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    render(conn, "show.html", institution: institution)
  end

  def edit(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    changeset = Settings.change_institution(institution)
    render(conn, "edit.html", institution: institution, changeset: changeset)
  end

  def update(conn, %{"id" => id, "institution" => institution_params}) do
    institution = Settings.get_institution!(id)

    case Settings.update_institution(institution, institution_params) do
      {:ok, institution} ->
        conn
        |> put_flash(:info, "Institution updated successfully.")
        |> redirect(to: institution_path(conn, :show, institution))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", institution: institution, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    {:ok, _institution} = Settings.delete_institution(institution)

    conn
    |> put_flash(:info, "Institution deleted successfully.")
    |> redirect(to: institution_path(conn, :index))
  end
end
