defmodule SchoolWeb.HolidayController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Holiday
  require IEx

  def index(conn, _params) do
     ins_id=conn.private.plug_session["institution_id"]
    holiday = Affairs.list_holiday()|>Enum.filter(fn x -> x.institution_id ==ins_id end)
    render(conn, "index.html", holiday: holiday)
  end

  def new(conn, _params) do

    changeset = Affairs.change_holiday(%Holiday{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"holiday" => holiday_params}) do


    ins_id=conn.private.plug_session["institution_id"]
    holiday_params=Map.put(holiday_params,"institution_id", ins_id)

    case Affairs.create_holiday(holiday_params) do
      {:ok, holiday} ->
        conn
        |> put_flash(:info, "Holiday created successfully.")
        |> redirect(to: holiday_path(conn, :show, holiday))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def holiday_report(conn,params) do
  semesters = Repo.all(from(s in Semester))

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
end
