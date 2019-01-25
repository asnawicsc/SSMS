defmodule SchoolWeb.MarkSheetHistoryController do
  use SchoolWeb, :controller
require IEx
  alias School.Affairs
  alias School.Affairs.MarkSheetHistory

  def index(conn, _params) do
    mark_sheet_history = Affairs.list_mark_sheet_history()
    render(conn, "index.html", mark_sheet_history: mark_sheet_history)
  end

  

  def new(conn, _params) do
    changeset = Affairs.change_mark_sheet_history(%MarkSheetHistory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mark_sheet_history" => mark_sheet_history_params}) do
    case Affairs.create_mark_sheet_history(mark_sheet_history_params) do
      {:ok, mark_sheet_history} ->
        conn
        |> put_flash(:info, "Mark sheet history created successfully.")
        |> redirect(to: mark_sheet_history_path(conn, :show, mark_sheet_history))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mark_sheet_history = Affairs.get_mark_sheet_history!(id)
    render(conn, "show.html", mark_sheet_history: mark_sheet_history)
  end

  def edit(conn, %{"id" => id}) do
    mark_sheet_history = Affairs.get_mark_sheet_history!(id)
    changeset = Affairs.change_mark_sheet_history(mark_sheet_history)
    render(conn, "edit.html", mark_sheet_history: mark_sheet_history, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mark_sheet_history" => mark_sheet_history_params}) do
    mark_sheet_history = Affairs.get_mark_sheet_history!(id)

    case Affairs.update_mark_sheet_history(mark_sheet_history, mark_sheet_history_params) do
      {:ok, mark_sheet_history} ->
        conn
        |> put_flash(:info, "Mark sheet history updated successfully.")
        |> redirect(to: mark_sheet_history_path(conn, :show, mark_sheet_history))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mark_sheet_history: mark_sheet_history, changeset: changeset)
    end
  end



  def delete(conn, %{"id" => id}) do
    mark_sheet_history = Affairs.get_mark_sheet_history!(id)
    {:ok, _mark_sheet_history} = Affairs.delete_mark_sheet_history(mark_sheet_history)

    conn
    |> put_flash(:info, "Mark sheet history deleted successfully.")
    |> redirect(to: mark_sheet_history_path(conn, :index))
  end
end
