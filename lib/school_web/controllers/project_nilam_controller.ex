defmodule SchoolWeb.ProjectNilamController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ProjectNilam
  require IEx

  def index(conn, _params) do
    project_nilam = Affairs.list_project_nilam()|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    render(conn, "index.html", project_nilam: project_nilam)
  end

    def nilam_setting(conn, _params) do

    level = Repo.all(from(s in School.Affairs.Level, select: %{institution_id: s.institution_id,id: s.id, name: s.name}))|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    project_nilam = Affairs.list_project_nilam()|>Enum.filter(fn x-> x.institution_id ==conn.private.plug_session["institution_id"] end)
    jauhari = Affairs.list_jauhari()
    rakan = Affairs.list_rakan()

    render(conn, "nilam_setting.html",level: level, project_nilam: project_nilam,jauhari: jauhari,rakan: rakan)
  end

  def edit_project_nilam(conn,params) do
      project_nilam = Affairs.get_project_nilam!(params["id"])

      project_nilam_params=%{below_satisfy: params["below_satisfy"],member_reading_quantity: params["member_reading_quantity"],page: params["page"]}

  Affairs.update_project_nilam(project_nilam, project_nilam_params)
 conn
        |> put_flash(:info, "Project nilam update successfully.")
        |> redirect(to: project_nilam_path(conn, :nilam_setting))

  end

  def new(conn, _params) do
    changeset = Affairs.change_project_nilam(%ProjectNilam{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project_nilam" => project_nilam_params}) do

       project_nilam_params = Map.put(project_nilam_params, "institution_id", conn.private.plug_session["institution_id"])
    case Affairs.create_project_nilam(project_nilam_params) do
      {:ok, project_nilam} ->
        conn
        |> put_flash(:info, "Project nilam created successfully.")
        |> redirect(to: project_nilam_path(conn, :show, project_nilam))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    project_nilam = Affairs.get_project_nilam!(id)
    render(conn, "show.html", project_nilam: project_nilam)
  end

  def edit(conn, %{"id" => id}) do
    project_nilam = Affairs.get_project_nilam!(id)
    changeset = Affairs.change_project_nilam(project_nilam)
    render(conn, "edit.html", project_nilam: project_nilam, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project_nilam" => project_nilam_params}) do
    project_nilam = Affairs.get_project_nilam!(id)

    case Affairs.update_project_nilam(project_nilam, project_nilam_params) do
      {:ok, project_nilam} ->
        conn
        |> put_flash(:info, "Project nilam updated successfully.")
        |> redirect(to: project_nilam_path(conn, :show, project_nilam))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", project_nilam: project_nilam, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project_nilam = Affairs.get_project_nilam!(id)
    {:ok, _project_nilam} = Affairs.delete_project_nilam(project_nilam)

    conn
    |> put_flash(:info, "Project nilam deleted successfully.")
    |> redirect(to: project_nilam_path(conn, :index))
  end
end
