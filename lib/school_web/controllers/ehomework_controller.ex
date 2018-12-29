defmodule SchoolWeb.EhomeworkController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Ehomework
  require IEx

  def ehomework(conn, params) do
    user = Repo.get(User, conn.private.plug_session["user_id"])
    class = Repo.get(Class, params["class_id"])

    subjects =
      Repo.all(
        from(
          st in SubjectTeachClass,
          left_join: c in Class,
          on: st.class_id == c.id,
          left_join: s in Subject,
          on: st.subject_id == s.id,
          where: c.id == ^class.id,
          select: %{
            description: s.description,
            subject_id: s.id
          }
        )
      )

    render(conn, "ehomework.html", class: class, subjects: subjects)
  end

  def show_ehomework_calendar(conn, params) do
    all =
      Repo.all(
        from(
          e in Ehomework,
          select: %{class_id: e.class_id, start: e.start_date, end: e.end_date}
        )
      )
      |> Enum.uniq()

    all =
      for each <- all do
        each = Map.put(each, :end_date, each.end)
        end_datetime = each.end |> Date.to_string()

        {:ok, end_datetime, 0} =
          Enum.join([end_datetime, "T00:00:00.000Z"], "") |> DateTime.from_iso8601()

        each = Map.put(each, :end, end_datetime)
        start_datetime = each.end |> Date.to_string()

        {:ok, start_datetime, 0} =
          Enum.join([start_datetime, "T00:00:00.000Z"], "") |> DateTime.from_iso8601()

        each = Map.put(each, :start, start_datetime)
        each = Map.put(each, :title, "View assignment?")
        each = Map.put(each, :description, nil)
        each
      end
      |> Poison.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, all)

    # DateTime.from_iso8601(a)

    # T00:00:00.000Z
  end

  def view_homework(conn, params) do
    homeworks =
      Repo.all(
        from(
          e in Ehomework,
          where:
            e.class_id == ^params["class_id"] and
              e.end_date == ^Date.from_iso8601!(params["end_date"])
        )
      )

    render(conn, "homework_details.html", homeworks: homeworks, end_date: params["end_date"])
  end

  def update_ehomework(conn, params) do
    ehomework = Repo.get(Ehomework, params["ehomework_id"])
    ehomework_params = %{desc: params["desc"]}

    case Affairs.update_ehomework(ehomework, ehomework_params) do
      {:ok, ehomework} ->
        homeworks =
          Repo.all(
            from(
              e in Ehomework,
              where: e.class_id == ^ehomework.class_id and e.end_date == ^ehomework.end_date
            )
          )

        conn
        |> put_flash(:info, "Ehomework updated successfully.")
        |> render(
          "homework_details.html",
          homeworks: homeworks,
          end_date: Date.to_string(ehomework.end_date)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        nil
    end
  end

  def index(conn, _params) do
    ehehomeworks = Affairs.list_ehehomeworks()
    render(conn, "index.html", ehehomeworks: ehehomeworks)
  end

  def new(conn, _params) do
    changeset = Affairs.change_ehomework(%Ehomework{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"ehomework" => ehomework_params}) do
    case Affairs.create_ehomework(ehomework_params) do
      {:ok, ehomework} ->
        conn
        |> put_flash(:info, "Ehomework created successfully.")
        |> redirect(to: ehomework_path(conn, :show, ehomework))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ehomework = Affairs.get_ehomework!(id)
    render(conn, "show.html", ehomework: ehomework)
  end

  def edit(conn, %{"id" => id}) do
    ehomework = Affairs.get_ehomework!(id)
    changeset = Affairs.change_ehomework(ehomework)
    render(conn, "edit.html", ehomework: ehomework, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ehomework" => ehomework_params}) do
    ehomework = Affairs.get_ehomework!(id)

    case Affairs.update_ehomework(ehomework, ehomework_params) do
      {:ok, ehomework} ->
        conn
        |> put_flash(:info, "Ehomework updated successfully.")
        |> redirect(to: ehomework_path(conn, :show, ehomework))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", ehomework: ehomework, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ehomework = Affairs.get_ehomework!(id)
    {:ok, _ehomework} = Affairs.delete_ehomework(ehomework)

    conn
    |> put_flash(:info, "Ehomework deleted successfully.")
    |> redirect(to: ehomework_path(conn, :index))
  end
end
