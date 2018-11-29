defmodule SchoolWeb.ListRankController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.ListRank

  def index(conn, _params) do
    list_rank =
      Affairs.list_list_rank()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", list_rank: list_rank)
  end

  def default_rank(conn, _params) do
    Repo.delete_all(
      from(s in School.Affairs.ListRank,
        where: s.institution_id == ^conn.private.plug_session["institution_id"]
      )
    )

    Affairs.create_list_rank(%{
      name: "Pengerusi",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Ketua Rumah",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Kapten Pasukan",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Naib Pengerusi",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Penolong Kapten",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Penolong Ketua Rumah",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Setiausaha",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Bendahari",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Penolong Setiausaha",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Penolong Bendahari",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Ahli Jawantankuasa",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Ahli Aktif",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_list_rank(%{
      name: "Ahli Berdaftar",
      mark: 0,
      institution_id: conn.private.plug_session["institution_id"]
    })

    list_rank = Affairs.list_list_rank()

    conn
    |> put_flash(:info, "List Rank updated successfully.")
    |> redirect(to: list_rank_path(conn, :index, list_rank))
  end

  def new(conn, _params) do
    changeset = Affairs.change_list_rank(%ListRank{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"list_rank" => list_rank_params}) do
    list_rank_params =
      Map.put(list_rank_params, "institution_id", conn.private.plug_session["institution_id"])

    case Affairs.create_list_rank(list_rank_params) do
      {:ok, list_rank} ->
        conn
        |> put_flash(:info, "List rank created successfully.")
        |> redirect(to: list_rank_path(conn, :show, list_rank))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    list_rank = Affairs.get_list_rank!(id)
    render(conn, "show.html", list_rank: list_rank)
  end

  def edit(conn, %{"id" => id}) do
    list_rank = Affairs.get_list_rank!(id)
    changeset = Affairs.change_list_rank(list_rank)
    render(conn, "edit.html", list_rank: list_rank, changeset: changeset)
  end

  def update(conn, %{"id" => id, "list_rank" => list_rank_params}) do
    list_rank = Affairs.get_list_rank!(id)

    case Affairs.update_list_rank(list_rank, list_rank_params) do
      {:ok, list_rank} ->
        conn
        |> put_flash(:info, "List rank updated successfully.")
        |> redirect(to: list_rank_path(conn, :show, list_rank))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", list_rank: list_rank, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    list_rank = Affairs.get_list_rank!(id)
    {:ok, _list_rank} = Affairs.delete_list_rank(list_rank)

    conn
    |> put_flash(:info, "List rank deleted successfully.")
    |> redirect(to: list_rank_path(conn, :index))
  end
end
