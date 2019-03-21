defmodule SchoolWeb.ShiftMasterController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ShiftMaster

  def index(conn, _params) do
    shift_master = Affairs.list_shift_master()
    render(conn, "index.html", shift_master: shift_master)
  end

  def new(conn, _params) do
    changeset = Affairs.change_shift_master(%ShiftMaster{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shift_master" => shift_master_params}) do
    case Affairs.create_shift_master(shift_master_params) do
      {:ok, shift_master} ->
        conn
        |> put_flash(:info, "Shift master created successfully.")
        |> redirect(to: shift_master_path(conn, :show, shift_master))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shift_master = Affairs.get_shift_master!(id)
    render(conn, "show.html", shift_master: shift_master)
  end

  def edit(conn, %{"id" => id}) do
    shift_master = Affairs.get_shift_master!(id)
    changeset = Affairs.change_shift_master(shift_master)
    render(conn, "edit.html", shift_master: shift_master, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shift_master" => shift_master_params}) do
    shift_master = Affairs.get_shift_master!(id)

    case Affairs.update_shift_master(shift_master, shift_master_params) do
      {:ok, shift_master} ->
        conn
        |> put_flash(:info, "Shift master updated successfully.")
        |> redirect(to: shift_master_path(conn, :show, shift_master))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", shift_master: shift_master, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shift_master = Affairs.get_shift_master!(id)
    {:ok, _shift_master} = Affairs.delete_shift_master(shift_master)

    conn
    |> put_flash(:info, "Shift master deleted successfully.")
    |> redirect(to: shift_master_path(conn, :index))
  end
end
