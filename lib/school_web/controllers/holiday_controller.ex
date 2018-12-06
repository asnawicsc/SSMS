defmodule SchoolWeb.HolidayController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Holiday
  require IEx

  def index(conn, _params) do
    ins_id = conn.private.plug_session["institution_id"]
    holiday = Affairs.list_holiday() |> Enum.filter(fn x -> x.institution_id == ins_id end)
    render(conn, "index.html", holiday: holiday)
  end

  def new(conn, _params) do
    changeset = Affairs.change_holiday(%Holiday{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"holiday" => holiday_params}) do
    ins_id = conn.private.plug_session["institution_id"]
    holiday_params = Map.put(holiday_params, "institution_id", ins_id)

    case Affairs.create_holiday(holiday_params) do
      {:ok, holiday} ->
        conn
        |> put_flash(:info, "Holiday created successfully.")
        |> redirect(to: holiday_path(conn, :show, holiday))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def holiday_report(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "holiday_listing.html", semesters: semesters)
  end

  def show(conn, %{"id" => id}) do
    holiday = Affairs.get_holiday!(id)
    render(conn, "show.html", holiday: holiday)
  end

  def edit(conn, %{"id" => id}) do
    holiday = Affairs.get_holiday!(id)
    changeset = Affairs.change_holiday(holiday)
    render(conn, "edit.html", holiday: holiday, changeset: changeset)
  end

  def update(conn, %{"id" => id, "holiday" => holiday_params}) do
    holiday = Affairs.get_holiday!(id)

    case Affairs.update_holiday(holiday, holiday_params) do
      {:ok, holiday} ->
        conn
        |> put_flash(:info, "Holiday updated successfully.")
        |> redirect(to: holiday_path(conn, :show, holiday))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", holiday: holiday, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    holiday = Affairs.get_holiday!(id)
    {:ok, _holiday} = Affairs.delete_holiday(holiday)

    conn
    |> put_flash(:info, "Holiday deleted successfully.")
    |> redirect(to: holiday_path(conn, :index))
  end

  def pre_generate_holiday(conn, params) do
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

  def upload_holiday(conn, params) do
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

        date =
          class_param["date"]
          |> String.replace("/", "-")
          |> String.split("-")
          |> List.to_tuple()

        year = date |> elem(0)

        month = date |> elem(1)

        a_month =
          if String.length(month) == 1 do
            "0" <> month
          else
            month
          end

        day = date |> elem(2)

        a_day =
          if String.length(day) == 1 do
            "0" <> day
          else
            day
          end

        date = (year <> "-" <> a_month <> "-" <> a_day) |> Date.from_iso8601!()

        class_param = Map.put(class_param, "date", date)

        class_param = Map.put(class_param, "description", class_param["description"])

        class_param =
          Map.put(class_param, "institution_id", conn.private.plug_session["institution_id"])

        class_param =
          Map.put(class_param, "semester_id", conn.private.plug_session["semester_id"])

        cg = Holiday.changeset(%Holiday{}, class_param)

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
    |> put_flash(:info, "Holiday created successfully.")
    |> redirect(to: holiday_path(conn, :index))
  end
end
