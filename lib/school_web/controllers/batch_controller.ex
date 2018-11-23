defmodule SchoolWeb.BatchController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.Batch

  def index(conn, _params) do
    batches = Settings.list_batches()
    render(conn, "index.html", batches: batches)
  end

  def new(conn, _params) do
    changeset = Settings.change_batch(%Batch{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"batch" => batch_params}) do
    case Settings.create_batch(batch_params) do
      {:ok, batch} ->
        conn
        |> put_flash(:info, "Batch created successfully.")
        |> redirect(to: batch_path(conn, :show, batch))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    batch = Settings.get_batch!(id)
    render(conn, "show.html", batch: batch)
  end

  def edit(conn, %{"id" => id}) do
    batch = Settings.get_batch!(id)
    changeset = Settings.change_batch(batch)
    render(conn, "edit.html", batch: batch, changeset: changeset)
  end

  def update(conn, %{"id" => id, "batch" => batch_params}) do
    batch = Settings.get_batch!(id)

    case Settings.update_batch(batch, batch_params) do
      {:ok, batch} ->
        conn
        |> put_flash(:info, "Batch updated successfully.")
        |> redirect(to: batch_path(conn, :show, batch))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", batch: batch, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    batch = Settings.get_batch!(id)
    {:ok, _batch} = Settings.delete_batch(batch)

    conn
    |> put_flash(:info, "Batch deleted successfully.")
    |> redirect(to: batch_path(conn, :index))
  end
end
