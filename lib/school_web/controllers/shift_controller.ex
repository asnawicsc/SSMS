defmodule SchoolWeb.ShiftController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Shift

  def index(conn, _params) do
    shift = Affairs.list_shift()
    render(conn, "index.html", shift: shift)
  end

  def new(conn, _params) do
    changeset = Affairs.change_shift(%Shift{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shift" => shift_params}) do
    case Affairs.create_shift(shift_params) do
      {:ok, shift} ->
        conn
        |> put_flash(:info, "Shift created successfully.")
        |> redirect(to: shift_path(conn, :show, shift))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shift = Affairs.get_shift!(id)
    render(conn, "show.html", shift: shift)
  end

  def edit(conn, %{"id" => id}) do
    shift = Affairs.get_shift!(id)
    changeset = Affairs.change_shift(shift)
    render(conn, "edit.html", shift: shift, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shift" => shift_params}) do
    shift = Affairs.get_shift!(id)

    case Affairs.update_shift(shift, shift_params) do
      {:ok, shift} ->
        conn
        |> put_flash(:info, "Shift updated successfully.")
        |> redirect(to: shift_path(conn, :show, shift))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", shift: shift, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shift = Affairs.get_shift!(id)
    {:ok, _shift} = Affairs.delete_shift(shift)

    conn
    |> put_flash(:info, "Shift deleted successfully.")
    |> redirect(to: shift_path(conn, :index))
  end
end
