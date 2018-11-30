defmodule SchoolWeb.LevelController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Level

  def index(conn, _params) do
    levels =
      Affairs.list_levels()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", levels: levels)
  end

  def new(conn, _params) do
    changeset = Affairs.change_level(%Level{})
    render(conn, "new.html", changeset: changeset)
  end

  def default_standard(conn, _params) do
    inst_id = Affairs.get_inst_id(conn)

    Repo.delete_all(
      from(
        s in School.Affairs.Level,
        where: s.institution_id == ^inst_id
      )
    )

    Affairs.create_level(%{
      name: "Standard 1",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_level(%{
      name: "Standard 2",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_level(%{
      name: "Standard 3",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_level(%{
      name: "Standard 4",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_level(%{
      name: "Standard 5",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_level(%{
      name: "Standard 6",
      institution_id: conn.private.plug_session["institution_id"]
    })

    levels = Affairs.list_levels()

    conn
    |> put_flash(:info, "Level updated successfully.")
    |> redirect(to: level_path(conn, :index, levels))
  end

  def create(conn, %{"level" => level_params}) do
    level_params =
      Map.put(level_params, "institution_id", conn.private.plug_session["institution_id"])

    case Affairs.create_level(level_params) do
      {:ok, level} ->
        conn
        |> put_flash(:info, "Level created successfully.")
        |> redirect(to: level_path(conn, :show, level))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    level = Affairs.get_level!(id)
    render(conn, "show.html", level: level)
  end

  def edit(conn, %{"id" => id}) do
    level = Affairs.get_level!(id)
    changeset = Affairs.change_level(level)
    render(conn, "edit.html", level: level, changeset: changeset)
  end

  def update(conn, %{"id" => id, "level" => level_params}) do
    level = Affairs.get_level!(id)

    case Affairs.update_level(level, level_params) do
      {:ok, level} ->
        conn
        |> put_flash(:info, "Level updated successfully.")
        |> redirect(to: level_path(conn, :show, level))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", level: level, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    level = Affairs.get_level!(id)
    {:ok, _level} = Affairs.delete_level(level)

    conn
    |> put_flash(:info, "Level deleted successfully.")
    |> redirect(to: level_path(conn, :index))
  end
end
