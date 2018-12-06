defmodule SchoolWeb.SemesterController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Semester
  require IEx

  def index(conn, _params) do
    semesters =
      Affairs.list_semesters()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", semesters: semesters)
  end

  def new(conn, _params) do
    changeset =
      Affairs.change_semester(%Semester{
        start_date: Timex.today(),
        end_date: Timex.today(),
        holiday_start: Timex.today(),
        holiday_end: Timex.today()
      })

    render(conn, "new.html", changeset: changeset)
  end

  def create_semesters(conn, params) do
    render(conn, "create_semesters.html")
  end

  def create_semesters_data(conn, params) do
    params = Map.put(params, "institution_id", conn.private.plug_session["institution_id"])

    case Affairs.create_semester(params) do
      {:ok, semester} ->
        conn
        |> put_flash(:info, "Semester created successfully.")
        |> redirect(to: semester_path(conn, :show, semester))
    end
  end

  def create(conn, %{"semester" => semester_params}) do
    semester_params =
      Map.put(semester_params, "institution_id", conn.private.plug_session["institution_id"])

    case Affairs.create_semester(semester_params) do
      {:ok, semester} ->
        conn
        |> put_flash(:info, "Semester created successfully.")
        |> redirect(to: semester_path(conn, :show, semester))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    semester = Affairs.get_semester!(id)
    render(conn, "show.html", semester: semester)
  end

  def edit(conn, %{"id" => id}) do
    semester = Affairs.get_semester!(id)
    changeset = Affairs.change_semester(semester)
    render(conn, "edit.html", semester: semester, changeset: changeset)
  end

  def update(conn, %{"id" => id, "semester" => semester_params}) do
    semester = Affairs.get_semester!(id)

    case Affairs.update_semester(semester, semester_params) do
      {:ok, semester} ->
        conn
        |> put_flash(:info, "Semester updated successfully.")
        |> redirect(to: semester_path(conn, :show, semester))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", semester: semester, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    semester = Affairs.get_semester!(id)
    {:ok, _semester} = Affairs.delete_semester(semester)

    conn
    |> put_flash(:info, "Semester deleted successfully.")
    |> redirect(to: semester_path(conn, :index))
  end

  def pre_generate_semester(conn, params) do
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

  def upload_semester(conn, params) do
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

    contents = tl(data) |> Enum.reject(fn x -> x == [""] end) |> Enum.uniq() |> Enum.sort()

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

        class_param = Enum.zip(h, c) |> Enum.into(%{})

        start_date =
          class_param["start_date"]
          |> String.split_at(10)
          |> elem(0)
          |> String.replace(".", "-")
          |> String.split_at(2)

        day = start_date |> elem(0)

        month = start_date |> elem(1) |> String.split_at(4) |> elem(0)

        year = start_date |> elem(1) |> String.split_at(4) |> elem(1)

        start_date = (year <> month <> day) |> Date.from_iso8601!()

        end_date =
          class_param["end_date"]
          |> String.split_at(10)
          |> elem(0)
          |> String.replace(".", "-")
          |> String.split_at(2)

        day = end_date |> elem(0)

        month = end_date |> elem(1) |> String.split_at(4) |> elem(0)

        year = end_date |> elem(1) |> String.split_at(4) |> elem(1)

        end_date = (year <> month <> day) |> Date.from_iso8601!()

        class_param = Map.put(class_param, "start_date", start_date)

        class_param = Map.put(class_param, "end_date", end_date)

        class_param =
          Map.put(class_param, "institution_id", conn.private.plug_session["institution_id"])

        cg = Semester.changeset(%Semester{}, class_param)

        case Repo.insert(cg) do
          {:ok, class} ->
            class_param
            class_param = Map.put(class_param, "reason", "ok")

          {:error, changeset} ->
            errors = changeset.errors |> Keyword.keys()

            {reason, message} = changeset.errors |> hd()
            {proper_message, message_list} = message
            final_reason = Atom.to_string(reason) <> " " <> proper_message
            class_param = Map.put(class_param, "reason", final_reason)

            class_param
        end
      end

    header = result |> hd() |> Map.keys()
    body = result |> Enum.map(fn x -> Map.values(x) end)

    new_io = List.insert_at(body, 0, header) |> CSV.encode() |> Enum.to_list() |> to_string
    {:ok, batch} = Settings.update_batch(batch, %{result: new_io})

    conn
    |> put_flash(:info, "Semester created successfully.")
    |> redirect(to: semester_path(conn, :index))
  end
end
