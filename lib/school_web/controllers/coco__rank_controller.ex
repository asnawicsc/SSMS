defmodule SchoolWeb.Coco_RankController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Coco_Rank

  def index(conn, _params) do
    coco_ranks = Affairs.list_coco_ranks()
    render(conn, "index.html", coco_ranks: coco_ranks)
  end

  def new(conn, _params) do
    changeset = Affairs.change_coco__rank(%Coco_Rank{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"coco__rank" => coco__rank_params}) do
    case Affairs.create_coco__rank(coco__rank_params) do
      {:ok, coco__rank} ->
        conn
        |> put_flash(:info, "Coco  rank created successfully.")
        |> redirect(to: coco__rank_path(conn, :show, coco__rank))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    coco__rank = Affairs.get_coco__rank!(id)
    render(conn, "show.html", coco__rank: coco__rank)
  end

  def edit(conn, %{"id" => id}) do
    coco__rank = Affairs.get_coco__rank!(id)
    changeset = Affairs.change_coco__rank(coco__rank)
    render(conn, "edit.html", coco__rank: coco__rank, changeset: changeset)
  end

  def update(conn, %{"id" => id, "coco__rank" => coco__rank_params}) do
    coco__rank = Affairs.get_coco__rank!(id)

    case Affairs.update_coco__rank(coco__rank, coco__rank_params) do
      {:ok, coco__rank} ->
        conn
        |> put_flash(:info, "Coco  rank updated successfully.")
        |> redirect(to: coco__rank_path(conn, :show, coco__rank))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", coco__rank: coco__rank, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    coco__rank = Affairs.get_coco__rank!(id)
    {:ok, _coco__rank} = Affairs.delete_coco__rank(coco__rank)

    conn
    |> put_flash(:info, "Coco  rank deleted successfully.")
    |> redirect(to: coco__rank_path(conn, :index))
  end
end
