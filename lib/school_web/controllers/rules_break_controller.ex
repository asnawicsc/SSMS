defmodule SchoolWeb.RulesBreakController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.RulesBreak

  def index(conn, _params) do
    rules_break = Affairs.list_rules_break()
    render(conn, "index.html", rules_break: rules_break)
  end

  def default_rules_break(conn, params) do
    Repo.delete_all(RulesBreak, institution_id: conn.private.plug_session["institution_id"])

    Affairs.create_rules_break(%{
      level: 1,
      remark: "Tahap Penguasaan Lemah",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_rules_break(%{
      level: 2,
      remark: "Tahap Penguasaan Memuaskan",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_rules_break(%{
      level: 3,
      remark: "Tahap Penguasaan Sederhana",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_rules_break(%{
      level: 4,
      remark: "Tahap Penguasaan Baik",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_rules_break(%{
      level: 5,
      remark: "Tahap Penguasaan Cemerlang",
      institution_id: conn.private.plug_session["institution_id"]
    })

    Affairs.create_rules_break(%{
      level: 6,
      remark: "Tahap Penguasaan Sangat Cemerlang",
      institution_id: conn.private.plug_session["institution_id"]
    })

    rules_break = Affairs.list_rules_break()

    conn
    |> put_flash(:info, "RulesBreak updated successfully.")
    |> redirect(to: rules_break_path(conn, :index, rules_break))
  end

  def new(conn, _params) do
    changeset = Affairs.change_rules_break(%RulesBreak{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"rules_break" => rules_break_params}) do
    case Affairs.create_rules_break(rules_break_params) do
      {:ok, rules_break} ->
        conn
        |> put_flash(:info, "Rules break created successfully.")
        |> redirect(to: rules_break_path(conn, :show, rules_break))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    rules_break = Affairs.get_rules_break!(id)
    render(conn, "show.html", rules_break: rules_break)
  end

  def edit(conn, %{"id" => id}) do
    rules_break = Affairs.get_rules_break!(id)
    changeset = Affairs.change_rules_break(rules_break)
    render(conn, "edit.html", rules_break: rules_break, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rules_break" => rules_break_params}) do
    rules_break = Affairs.get_rules_break!(id)

    case Affairs.update_rules_break(rules_break, rules_break_params) do
      {:ok, rules_break} ->
        conn
        |> put_flash(:info, "Rules break updated successfully.")
        |> redirect(to: rules_break_path(conn, :show, rules_break))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", rules_break: rules_break, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rules_break = Affairs.get_rules_break!(id)
    {:ok, _rules_break} = Affairs.delete_rules_break(rules_break)

    conn
    |> put_flash(:info, "Rules break deleted successfully.")
    |> redirect(to: rules_break_path(conn, :index))
  end
end
