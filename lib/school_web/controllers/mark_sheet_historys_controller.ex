defmodule SchoolWeb.MarkSheetHistorysController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.MarkSheetHistorys

  require IEx

  def index(conn, _params) do
    mark_sheet_historys = Affairs.list_mark_sheet_historys()

    render(conn, "index.html", mark_sheet_historys: mark_sheet_historys)
  end

  def new(conn, _params) do
    changeset = Affairs.change_mark_sheet_historys(%MarkSheetHistorys{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mark_sheet_historys" => mark_sheet_historys_params}) do
    case Affairs.create_mark_sheet_historys(mark_sheet_historys_params) do
      {:ok, mark_sheet_historys} ->
        conn
        |> put_flash(:info, "Mark sheet historys created successfully.")
        |> redirect(to: mark_sheet_historys_path(conn, :show, mark_sheet_historys))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mark_sheet_historys = Affairs.get_mark_sheet_historys!(id)
    render(conn, "show.html", mark_sheet_historys: mark_sheet_historys)
  end

  def edit(conn, %{"id" => id}) do
    mark_sheet_historys = Affairs.get_mark_sheet_historys!(id)
    changeset = Affairs.change_mark_sheet_historys(mark_sheet_historys)
    render(conn, "edit.html", mark_sheet_historys: mark_sheet_historys, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mark_sheet_historys" => mark_sheet_historys_params}) do
    mark_sheet_historys = Affairs.get_mark_sheet_historys!(id)

    case Affairs.update_mark_sheet_historys(mark_sheet_historys, mark_sheet_historys_params) do
      {:ok, mark_sheet_historys} ->
        conn
        |> put_flash(:info, "Mark sheet historys updated successfully.")
        |> redirect(to: mark_sheet_historys_path(conn, :show, mark_sheet_historys))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mark_sheet_historys: mark_sheet_historys, changeset: changeset)
    end
  end

  def pre_upload_mark_sheet_history(conn, params) do
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

  def upload_mark_sheet_history(conn, params) do
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

        class_param = Enum.zip(h, c) |> Enum.into(%{})

        class_param =
          Map.put(class_param, "institution_id", conn.private.plug_session["institution_id"])

        cg = MarkSheetHistorys.changeset(%MarkSheetHistorys{}, class_param)

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
  end

  def history_report_card_class(conn, params) do
    all =
      Repo.all(
        from(s in Affairs.MarkSheetHistorys,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.year == ^params["year"] and s.class == ^params["class_name"]
        )
      )

    if all == [] do
      conn
      |> put_flash(:info, "No Data for this Selection")
      |> redirect(to: exam_path(conn, :history_report_card))
    else
      a = all |> Enum.group_by(fn x -> x.stuid end)

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.MarkSheetHistorysView,
          "student_history_report_card.html",
          a: a
        )

      pdf_params = %{"html" => html}

      pdf_binary =
        PdfGenerator.generate_binary!(
          pdf_params["html"],
          size: "A4",
          shell_params: [
            "--margin-left",
            "5",
            "--margin-right",
            "5",
            "--margin-top",
            "5",
            "--margin-bottom",
            "5",
            "--encoding",
            "utf-8"
          ],
          delete_temporary: true
        )

      conn
      |> put_resp_header("Content-Type", "application/pdf")
      |> resp(200, pdf_binary)
    end
  end

  def delete(conn, %{"id" => id}) do
    mark_sheet_historys = Affairs.get_mark_sheet_historys!(id)
    {:ok, _mark_sheet_historys} = Affairs.delete_mark_sheet_historys(mark_sheet_historys)

    conn
    |> put_flash(:info, "Mark sheet historys deleted successfully.")
    |> redirect(to: mark_sheet_historys_path(conn, :index))
  end
end
