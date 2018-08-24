defmodule SchoolWeb.RakanController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Rakan

  def index(conn, _params) do
    rakan = Affairs.list_rakan()
    render(conn, "index.html", rakan: rakan)
  end

  def new(conn, _params) do
    changeset = Affairs.change_rakan(%Rakan{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"rakan" => rakan_params}) do
    case Affairs.create_rakan(rakan_params) do
      {:ok, rakan} ->
        conn
        |> put_flash(:info, "Rakan created successfully.")
        |> redirect(to: rakan_path(conn, :show, rakan))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    rakan = Affairs.get_rakan!(id)
    render(conn, "show.html", rakan: rakan)
  end

  def edit(conn, %{"id" => id}) do
    rakan = Affairs.get_rakan!(id)
    changeset = Affairs.change_rakan(rakan)
    render(conn, "edit.html", rakan: rakan, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rakan" => rakan_params}) do
    rakan = Affairs.get_rakan!(id)

    case Affairs.update_rakan(rakan, rakan_params) do
      {:ok, rakan} ->
        conn
        |> put_flash(:info, "Rakan updated successfully.")
        |> redirect(to: rakan_path(conn, :show, rakan))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", rakan: rakan, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rakan = Affairs.get_rakan!(id)
    {:ok, _rakan} = Affairs.delete_rakan(rakan)

    conn
    |> put_flash(:info, "Rakan deleted successfully.")
    |> redirect(to: rakan_path(conn, :index))
  end
end
