defmodule SchoolWeb.SyncListController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.SyncList

  def index(conn, _params) do
    sync_list = Affairs.list_sync_list()
    render(conn, "index.html", sync_list: sync_list)
  end

  def new(conn, _params) do
    changeset = Affairs.change_sync_list(%SyncList{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sync_list" => sync_list_params}) do
    case Affairs.create_sync_list(sync_list_params) do
      {:ok, sync_list} ->
        conn
        |> put_flash(:info, "Sync list created successfully.")
        |> redirect(to: sync_list_path(conn, :show, sync_list))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sync_list = Affairs.get_sync_list!(id)
    render(conn, "show.html", sync_list: sync_list)
  end

  def edit(conn, %{"id" => id}) do
    sync_list = Affairs.get_sync_list!(id)
    changeset = Affairs.change_sync_list(sync_list)
    render(conn, "edit.html", sync_list: sync_list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sync_list" => sync_list_params}) do
    sync_list = Affairs.get_sync_list!(id)

    case Affairs.update_sync_list(sync_list, sync_list_params) do
      {:ok, sync_list} ->
        conn
        |> put_flash(:info, "Sync list updated successfully.")
        |> redirect(to: sync_list_path(conn, :show, sync_list))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sync_list: sync_list, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sync_list = Affairs.get_sync_list!(id)
    {:ok, _sync_list} = Affairs.delete_sync_list(sync_list)

    conn
    |> put_flash(:info, "Sync list deleted successfully.")
    |> redirect(to: sync_list_path(conn, :index))
  end
end
