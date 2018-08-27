defmodule SchoolWeb.JauhariController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Jauhari

  def index(conn, _params) do
    jauhari = Affairs.list_jauhari()
    render(conn, "index.html", jauhari: jauhari)
  end

  def new(conn, _params) do
    changeset = Affairs.change_jauhari(%Jauhari{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"jauhari" => jauhari_params}) do
    case Affairs.create_jauhari(jauhari_params) do
      {:ok, jauhari} ->
        conn
        |> put_flash(:info, "Jauhari created successfully.")
        |> redirect(to: jauhari_path(conn, :show, jauhari))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    jauhari = Affairs.get_jauhari!(id)
    render(conn, "show.html", jauhari: jauhari)
  end

  def edit(conn, %{"id" => id}) do
    jauhari = Affairs.get_jauhari!(id)
    changeset = Affairs.change_jauhari(jauhari)
    render(conn, "edit.html", jauhari: jauhari, changeset: changeset)
  end

  def update(conn, %{"id" => id, "jauhari" => jauhari_params}) do
    jauhari = Affairs.get_jauhari!(id)

    case Affairs.update_jauhari(jauhari, jauhari_params) do
      {:ok, jauhari} ->
        conn
        |> put_flash(:info, "Jauhari updated successfully.")
        |> redirect(to: jauhari_path(conn, :show, jauhari))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", jauhari: jauhari, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    jauhari = Affairs.get_jauhari!(id)
    {:ok, _jauhari} = Affairs.delete_jauhari(jauhari)

    conn
    |> put_flash(:info, "Jauhari deleted successfully.")
    |> redirect(to: jauhari_path(conn, :index))
  end
end
