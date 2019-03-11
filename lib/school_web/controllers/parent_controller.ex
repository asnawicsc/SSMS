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
      Repo.all(
        from(s in Semester,
          order_by: [desc: s.year]
        )
      )
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

  def parents_corner(conn, params) do
    render(conn, "parents_corner.html", [])
  end

  def create(conn, %{"parent" => parent_params}) do
    parent_params =
      Map.put(parent_params, "institution_id", conn.private.plug_session["institution_id"])

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

  def match_parents_ic(conn, params) do
    icno = params["ic_no"] |> String.replace("-", "")

    user = Settings.current_user(conn)
    parent = Repo.get_by(Parent, icno: icno, email: user.email)

    IO.inspect(parent)
    IO.inspect(user)

    if parent != nil do
      Affairs.update_parent(parent, %{
        fb_user_id: user.fb_user_id,
        email: user.email,
        psid: user.psid
      })

      if user != parent do
        Repo.delete(user)
      end

      conn
      |> put_flash(
        :info,
        "Linking process done."
      )
      |> redirect(to: parent_path(conn, :parents_corner))
    else
      conn
      |> put_flash(
        :info,
        "We couldnt find the matching IC, kindly contact the school administrator."
      )
      |> redirect(to: parent_path(conn, :parents_corner))
    end
  end

  def login(conn, params) do
    render(conn, "login.html", [])
  end

  def show_guardian(conn, params) do
    parent =
      Affairs.list_parent()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    if parent == [] do
      student = Repo.get_by(Student, student_no: params["student_no"])

      conn
      |> put_flash(:info, "Please Insert Parent Information")
      |> redirect(to: class_path(conn, :show_student_info, student.id))
    else
      guardian = Repo.get_by(Parent, icno: params["id"])

      if guardian != nil do
        changeset = Affairs.change_parent(guardian)
        render(conn, "edit.html", parent: guardian, changeset: changeset)
      else
        student = Repo.get_by(Student, student_no: params["student_no"])

        conn
        |> put_flash(:info, "This parent information does not exist")
        |> redirect(to: class_path(conn, :show_student_info, student.id))
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    parent = Affairs.get_parent!(id)
    changeset = Affairs.change_parent(parent)
    render(conn, "edit.html", parent: parent, changeset: changeset)
  end

  def update(conn, %{"id" => id, "parent" => parent_params}) do
    parent =
      Repo.get_by(
        Parent,
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

  def pre_upload_parents(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.create_batch(%{upload_by: usr.id, result: bin})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)

    render(conn, "adjust_header.html", headers: headers, batch_id: batch.id)
  end

  def upload_parents(conn, params) do
    batch = Settings.get_batch!(params["batch_id"])
    bin = batch.result
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.update_batch(batch, %{upload_by: usr.id})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers =
      hd(data)
      |> Enum.map(fn x -> String.trim(x, " ") end)
      |> Enum.map(fn x -> params["header"][x] end)

    contents = tl(data)

    result =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

        content = content |> Enum.map(fn x -> x end) |> Enum.filter(fn x -> x != "\"" end)

        c =
          for item <- content do
            item =
              case item do
                "@@@" ->
                  ","

                "\\N" ->
                  ""

                _ ->
                  item
              end

            a =
              case item do
                {:ok, i} ->
                  i

                _ ->
                  cond do
                    item == " " ->
                      "null"

                    item == "  " ->
                      "null"

                    item == "   " ->
                      "null"

                    true ->
                      item
                      |> String.split("\"")
                      |> Enum.map(fn x -> String.replace(x, "\n", "") end)
                      |> List.last()
                  end
              end
          end

        parent_params = Enum.zip(h, c) |> Enum.into(%{})

        parent_params =
          Map.put(parent_params, "institution_id", conn.private.plug_session["institution_id"])

        cg = Parent.changeset(%Parent{}, parent_params)

        case Repo.insert(cg) do
          {:ok, parent} ->
            parent_params
            parent_params = Map.put(parent_params, "reason", "ok")

          {:error, changeset} ->
            errors = changeset.errors |> Keyword.keys()

            {reason, message} = changeset.errors |> hd()
            {proper_message, message_list} = message
            final_reason = Atom.to_string(reason) <> " " <> proper_message
            parent_params = Map.put(parent_params, "reason", final_reason)

            parent_params
        end
      end

    header = result |> hd() |> Map.keys()
    body = result |> Enum.map(fn x -> Map.values(x) end)
    new_io = List.insert_at(body, 0, header) |> CSV.encode() |> Enum.to_list() |> to_string
    {:ok, batch} = Settings.update_batch(batch, %{result: new_io})

    conn
    |> put_flash(:info, "Parent created successfully.")
    |> redirect(to: parent_path(conn, :index))
  end

  def delete_duplicate_icno() do
    import Ecto.Query

    s_no =
      School.Repo.all(
        from(
          s in School.Affairs.Parent,
          group_by: [s.icno],
          select: %{ct: count(s.icno), no: s.icno}
        )
      )
      |> Enum.filter(fn x -> x.ct > 1 end)
      |> Enum.map(fn x -> x.no end)

    for s_n <- s_no do
      students = School.Repo.all(from(s in School.Affairs.Parent, where: s.icno == ^s_n))

      {student, dup_students} = List.pop_at(students, 0)
      Enum.map(dup_students, fn x -> School.Repo.delete(x) end)
    end
  end
end
