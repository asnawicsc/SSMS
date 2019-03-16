defmodule SchoolWeb.MarkSheetTempController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.MarkSheetTemp
  require IEx

  def index(conn, _params) do
    mark_sheet_temp =
      Affairs.list_mark_sheet_temp()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", mark_sheet_temp: mark_sheet_temp)
  end

  def new(conn, _params) do
    changeset = Affairs.change_mark_sheet_temp(%MarkSheetTemp{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mark_sheet_temp" => mark_sheet_temp_params}) do
    case Affairs.create_mark_sheet_temp(mark_sheet_temp_params) do
      {:ok, mark_sheet_temp} ->
        conn
        |> put_flash(:info, "Mark sheet temp created successfully.")
        |> redirect(to: mark_sheet_temp_path(conn, :show, mark_sheet_temp))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mark_sheet_temp = Affairs.get_mark_sheet_temp!(id)
    render(conn, "show.html", mark_sheet_temp: mark_sheet_temp)
  end

  def edit(conn, %{"id" => id}) do
    mark_sheet_temp = Affairs.get_mark_sheet_temp!(id)
    changeset = Affairs.change_mark_sheet_temp(mark_sheet_temp)
    render(conn, "edit.html", mark_sheet_temp: mark_sheet_temp, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mark_sheet_temp" => mark_sheet_temp_params}) do
    mark_sheet_temp = Affairs.get_mark_sheet_temp!(id)

    case Affairs.update_mark_sheet_temp(mark_sheet_temp, mark_sheet_temp_params) do
      {:ok, mark_sheet_temp} ->
        conn
        |> put_flash(:info, "Mark sheet temp updated successfully.")
        |> redirect(to: mark_sheet_temp_path(conn, :show, mark_sheet_temp))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mark_sheet_temp: mark_sheet_temp, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    mark_sheet_temp = Affairs.get_mark_sheet_temp!(id)
    {:ok, _mark_sheet_temp} = Affairs.delete_mark_sheet_temp(mark_sheet_temp)

    conn
    |> put_flash(:info, "Mark sheet temp deleted successfully.")
    |> redirect(to: mark_sheet_temp_path(conn, :index))
  end
end
