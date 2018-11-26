defmodule SchoolWeb.ParentController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Parent
  require IEx

  def parent_listing(conn, _params) do
    parent =
      Affairs.list_parent()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    classes =
      Repo.all(from(c in Class, where: c.institution_id == ^User.institution_id(conn)))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "parent_listing.html", parent: parent, semesters: semesters, classes: classes)
  end

  def guardian_listing(conn, _params) do
    parent =
      Affairs.list_parent()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    classes =
      Repo.all(from(c in Class, where: c.institution_id == ^User.institution_id(conn)))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", parent: parent, semesters: semesters, classes: classes)
  end

  def index(conn, _params) do
    parent = Affairs.list_parent(conn.private.plug_session["institution_id"])

    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    classes =
      Repo.all(from(c in Class, where: c.institution_id == ^User.institution_id(conn)))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", parent: parent, semesters: semesters, classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_parent(%Parent{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"parent" => parent_params}) do
    case Affairs.create_parent(parent_params) do
      {:ok, parent} ->
        conn
        |> put_flash(:info, "Parent created successfully.")
        |> redirect(to: parent_path(conn, :show, parent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    parent = Affairs.get_parent!(id)
    render(conn, "show.html", parent: parent)
  end

  def show_guardian(conn, %{"id" => id}) do
    guardian = Repo.get_by(Parent, icno: id)

    if guardian != [] do
      changeset = Affairs.change_parent(guardian)
      render(conn, "edit.html", parent: guardian, changeset: changeset)
    else
      conn
      |> put_flash(:info, "This parent information is not exist")
      |> redirect(to: student_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    parent = Affairs.get_parent!(id)
    changeset = Affairs.change_parent(parent)
    render(conn, "edit.html", parent: parent, changeset: changeset)
  end

  def update(conn, %{"id" => id, "parent" => parent_params}) do
    parent =
      Repo.get_by(Parent,
        icno: parent_params["icno"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    case Affairs.update_parent(parent, parent_params) do
      {:ok, parent} ->
        url = parent_path(conn, :index, focus: parent.icno)
        referer = conn.req_headers |> Enum.filter(fn x -> elem(x, 0) == "referer" end)

        if referer != [] do
          refer = hd(referer)
          url = refer |> elem(1) |> String.split("?") |> List.first()

          conn
          |> put_flash(:info, "#{parent.name} updated successfully.")
          |> redirect(external: url <> "?focus=#{parent.icno}")
        else
          conn
          |> put_flash(:info, "#{parent.name} updated successfully.")
          |> redirect(to: url)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    parent = Affairs.get_parent!(id)
    {:ok, _parent} = Affairs.delete_parent(parent)

    conn
    |> put_flash(:info, "Parent deleted successfully.")
    |> redirect(to: parent_path(conn, :index))
  end

  def upload_parents(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    data = bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)
    contents = tl(data)

    parents_params =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

        c =
          for item <- content do
            item = String.replace(item, "@@@", ",")

            case item do
              {:ok, i} ->
                i

              _ ->
                cond do
                  item == " " ->
                    "null"

                  item == "" ->
                    "null"

                  item == "  " ->
                    "null"

                  true ->
                    item

                    item
                    |> String.split("\"")
                    |> Enum.map(fn x -> String.replace(x, "\n", "") end)
                    |> List.last()
                end
            end
          end

        parents_params = Enum.zip(h, c) |> Enum.into(%{})

        if is_integer(parents_params["tanggn"]) do
          parents_params =
            Map.put(parents_params, "tanggn", Integer.to_string(parents_params["tanggn"]))
        end

        if is_integer(parents_params["income"]) do
          parents_params =
            Map.put(parents_params, "income", Integer.to_string(parents_params["income"]))
        end

        if is_integer(parents_params["state"]) do
          parents_params =
            Map.put(parents_params, "state", Integer.to_string(parents_params["state"]))
        end

        parents_params =
          Map.put(
            parents_params,
            "institution_id",
            Integer.to_string(conn.private.plug_session["institution_id"])
          )

        cg = Parent.changeset(%Parent{}, parents_params)

        case Repo.insert(cg) do
          {:ok, parent} ->
            {:ok, parent}

          {:error, cg} ->
            {:error, cg}
        end
      end

    conn
    |> put_flash(:info, "Parents created successfully.")
    |> redirect(to: parent_path(conn, :index))
  end
end
