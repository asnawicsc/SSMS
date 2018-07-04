defmodule SchoolWeb.ParameterController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.Parameter

  def index(conn, _params) do
    parameters = Settings.list_parameters()
    render(conn, "index.html", parameters: parameters)
  end

  def new(conn, _params) do
    changeset = Settings.change_parameter(%Parameter{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"parameter" => parameter_params}) do
    parameter_params = Map.put(parameter_params, "institution_id", conn.private.plug_session["institution_id"])
    case Settings.create_parameter(parameter_params) do
      {:ok, parameter} ->
        conn
        |> put_flash(:info, "Parameter created successfully.")
        |> redirect(to: parameter_path(conn, :show, parameter))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def system_config(conn, %{"institution_id" => id}) do
    parameter = Repo.get_by(Parameter, institution_id: id)
   
    render(conn, "show.html", parameter: parameter)
  end

  def show(conn, %{"id" => id}) do
    parameter = Settings.get_parameter!(id)
    render(conn, "show.html", parameter: parameter)
  end

  def edit(conn, %{"id" => id}) do
    parameter = Settings.get_parameter!(id)
    changeset = Settings.change_parameter(parameter)
    render(conn, "edit.html", parameter: parameter, changeset: changeset)
  end

  def update(conn, %{"id" => id, "parameter" => parameter_params}) do
    parameter = Settings.get_parameter!(id)
    parameter_params = Map.put(parameter_params, "institution_id", conn.private.plug_session["institution_id"])
    case Settings.update_parameter(parameter, parameter_params) do
      {:ok, parameter} ->
        conn
        |> put_flash(:info, "Parameter updated successfully.")
        |> redirect(to: parameter_path(conn, :show, parameter))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", parameter: parameter, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    parameter = Settings.get_parameter!(id)
    {:ok, _parameter} = Settings.delete_parameter(parameter)

    conn
    |> put_flash(:info, "Parameter deleted successfully.")
    |> redirect(to: parameter_path(conn, :index))
  end
end
