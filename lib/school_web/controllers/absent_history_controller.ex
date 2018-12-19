defmodule SchoolWeb.AbsentHistoryController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.AbsentHistory

  def index(conn, _params) do
    absent_history = Affairs.list_absent_history()
    render(conn, "index.html", absent_history: absent_history)
  end

  def history_absent(conn, params) do
    year =
      Affairs.list_absent_history()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
      |> Enum.map(fn x -> x.year end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != nil end)

    class_name =
      Affairs.list_absent_history()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
      |> Enum.map(fn x -> x.student_class end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != nil end)

    render(conn, "history_absent.html",
      year: year,
      class_name: class_name
    )
  end

  def pre_upload_absent_history(conn, params) do
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

  def upload_history_absent(conn, params) do
    batch = Settings.get_batch!(params["batch_id"])
    bin = batch.result
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.update_batch(batch, %{upload_by: usr.id})

    data =
      if bin |> String.contains?("\r") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers =
      hd(data)
      |> Enum.map(fn x -> String.trim(x, " ") end)
      |> Enum.map(fn x -> params["header"][x] end)
      |> Enum.reject(fn x -> x == nil end)

    contents = tl(data)

    Task.start_link(__MODULE__, :loop, [conn, contents, headers, batch])

    conn
    |> put_flash(:info, "History Record successfully added.")
    |> redirect(to: exam_path(conn, :list_report_history))
  end

  def loop(conn, contents, headers, batch) do
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

        absent_param = Enum.zip(h, c) |> Enum.into(%{})

        absent_param =
          Map.put(absent_param, "institution_id", conn.private.plug_session["institution_id"])

        cg = AbsentHistory.changeset(%AbsentHistory{}, absent_param)

        case Repo.insert(cg) do
          {:ok, student} ->
            absent_param
            absent_param = Map.put(absent_param, "reason", "ok")

          {:error, changeset} ->
            errors = changeset.errors |> Keyword.keys()

            {reason, message} = changeset.errors |> hd()
            {proper_message, message_list} = message
            final_reason = Atom.to_string(reason) <> " " <> proper_message
            absent_param = Map.put(absent_param, "reason", final_reason)

            absent_param
        end
      end

    header = result |> hd() |> Map.keys()
    body = result |> Enum.map(fn x -> Map.values(x) end)
    new_io = List.insert_at(body, 0, header) |> CSV.encode() |> Enum.to_list() |> to_string
    {:ok, batch} = Settings.update_batch(batch, %{result: new_io})
  end

  def history_absent_class(conn, params) do
    history_data =
      Repo.all(
        from(s in AbsentHistory,
          where:
            s.student_class == ^params["class_name"] and s.year == ^params["year"] and
              s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )
      |> Enum.sort_by(fn x -> x.student_no end)

    if history_data == [] do
      conn
      |> put_flash(:info, "No History Record for this selection.")
      |> redirect(to: absent_history_path(conn, :history_absent))
    else
      a = history_data

      render(conn, "result_history_absent.html",
        a: a,
        class_name: params["class_name"],
        year: params["year"]
      )
    end
  end

  def new(conn, _params) do
    changeset = Affairs.change_absent_history(%AbsentHistory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"absent_history" => absent_history_params}) do
    case Affairs.create_absent_history(absent_history_params) do
      {:ok, absent_history} ->
        conn
        |> put_flash(:info, "Absent history created successfully.")
        |> redirect(to: absent_history_path(conn, :show, absent_history))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    absent_history = Affairs.get_absent_history!(id)
    render(conn, "show.html", absent_history: absent_history)
  end

  def edit(conn, %{"id" => id}) do
    absent_history = Affairs.get_absent_history!(id)
    changeset = Affairs.change_absent_history(absent_history)
    render(conn, "edit.html", absent_history: absent_history, changeset: changeset)
  end

  def update(conn, %{"id" => id, "absent_history" => absent_history_params}) do
    absent_history = Affairs.get_absent_history!(id)

    case Affairs.update_absent_history(absent_history, absent_history_params) do
      {:ok, absent_history} ->
        conn
        |> put_flash(:info, "Absent history updated successfully.")
        |> redirect(to: absent_history_path(conn, :show, absent_history))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", absent_history: absent_history, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    absent_history = Affairs.get_absent_history!(id)
    {:ok, _absent_history} = Affairs.delete_absent_history(absent_history)

    conn
    |> put_flash(:info, "Absent history deleted successfully.")
    |> redirect(to: absent_history_path(conn, :index))
  end
end
