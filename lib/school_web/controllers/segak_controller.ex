defmodule SchoolWeb.SegakController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Segak

  def index(conn, _params) do
    segak = Affairs.list_segak()
    render(conn, "index.html", segak: segak)
  end

  def create_segak(conn, _params) do
    segak = Affairs.list_segak()

    classes =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    render(conn, "create_segak_mark.html", segak: segak, classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_segak(%Segak{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"segak" => segak_params}) do
    case Affairs.create_segak(segak_params) do
      {:ok, segak} ->
        conn
        |> put_flash(:info, "Segak created successfully.")
        |> redirect(to: segak_path(conn, :show, segak))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    segak = Affairs.get_segak!(id)
    render(conn, "show.html", segak: segak)
  end

  def edit(conn, %{"id" => id}) do
    segak = Affairs.get_segak!(id)
    changeset = Affairs.change_segak(segak)
    render(conn, "edit.html", segak: segak, changeset: changeset)
  end

  def update(conn, %{"id" => id, "segak" => segak_params}) do
    segak = Affairs.get_segak!(id)

    case Affairs.update_segak(segak, segak_params) do
      {:ok, segak} ->
        conn
        |> put_flash(:info, "Segak updated successfully.")
        |> redirect(to: segak_path(conn, :show, segak))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", segak: segak, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    segak = Affairs.get_segak!(id)
    {:ok, _segak} = Affairs.delete_segak(segak)

    conn
    |> put_flash(:info, "Segak deleted successfully.")
    |> redirect(to: segak_path(conn, :index))
  end
end
