defmodule SchoolWeb.ClassController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Class

  def index(conn, _params) do
    classes = Affairs.list_classes()
    render(conn, "index.html", classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_class(%Class{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"class" => class_params}) do
    case Affairs.create_class(class_params) do
      {:ok, class} ->
        conn
        |> put_flash(:info, "Class created successfully.")
        |> redirect(to: class_path(conn, :show, class))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)
    render(conn, "show.html", class: class)
  end

  def edit(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)
    changeset = Affairs.change_class(class)
    render(conn, "edit.html", class: class, changeset: changeset)
  end

  def update(conn, %{"id" => id, "class" => class_params}) do
    class = Affairs.get_class!(id)

    case Affairs.update_class(class, class_params) do
      {:ok, class} ->
        conn
        |> put_flash(:info, "Class updated successfully.")
        |> redirect(to: class_path(conn, :show, class))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", class: class, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)
    {:ok, _class} = Affairs.delete_class(class)

    conn
    |> put_flash(:info, "Class deleted successfully.")
    |> redirect(to: class_path(conn, :index))
  end
end
