defmodule SchoolWeb.AbsentController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Absent

  require IEx

  def index(conn, _params) do
    absent = Affairs.list_absent()
    render(conn, "index.html", absent: absent)
  end

  def new(conn, _params) do
    changeset = Affairs.change_absent(%Absent{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"absent" => absent_params}) do
    case Affairs.create_absent(absent_params) do
      {:ok, absent} ->
        conn
        |> put_flash(:info, "Absent created successfully.")
        |> redirect(to: absent_path(conn, :show, absent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    absent = Affairs.get_absent!(id)
    render(conn, "show.html", absent: absent)
  end

  def edit(conn, %{"id" => id}) do
    absent = Affairs.get_absent!(id)
    changeset = Affairs.change_absent(absent)
    render(conn, "edit.html", absent: absent, changeset: changeset)
  end

  def update(conn, %{"id" => id, "absent" => absent_params}) do
    absent = Affairs.get_absent!(id)

    case Affairs.update_absent(absent, absent_params) do
      {:ok, absent} ->
        conn
        |> put_flash(:info, "Absent updated successfully.")
        |> redirect(to: absent_path(conn, :show, absent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", absent: absent, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    absent = Affairs.get_absent!(id)
    {:ok, _absent} = Affairs.delete_absent(absent)

    conn
    |> put_flash(:info, "Absent deleted successfully.")
    |> redirect(to: absent_path(conn, :index))
  end

  def pre_generate_absent(conn, params) do
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

  def upload_absent(conn, params) do
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

        absent_date =
          class_param["absent_date"]
          |> String.replace("/", "-")
          |> String.split("-")
          |> List.to_tuple()

        year = absent_date |> elem(0)

        month = absent_date |> elem(1)

        a_month =
          if String.length(month) == 1 do
            "0" <> month
          else
            month
          end

        day = absent_date |> elem(2)

        a_day =
          if String.length(day) == 1 do
            "0" <> day
          else
            day
          end

        absent_date = (year <> "-" <> a_month <> "-" <> a_day) |> Date.from_iso8601!()

        reason = class_param["reason"]

        institution_id = conn.private.plug_session["institution_id"]

        class_id =
          Repo.get_by(Affairs.Class,
            name: class_param["class_name"],
            institution_id: conn.private.plug_session["institution_id"]
          ).id

        student_id = class_param["student_id"]

        semester_id =
          Repo.get_by(Affairs.Semester, year: class_param["year"], sem: class_param["sem"]).id

        class_param = Map.put(class_param, "absent_date", absent_date)

        class_param =
          Map.put(class_param, "institution_id", conn.private.plug_session["institution_id"])

        cg =
          Absent.changeset(%Absent{}, %{
            absent_date: absent_date,
            reason: reason,
            institution_id: institution_id,
            class_id: class_id,
            student_id: student_id,
            semester_id: semester_id
          })

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
    |> put_flash(:info, "Absent created successfully.")
    |> redirect(to: absent_path(conn, :index))
  end
end
