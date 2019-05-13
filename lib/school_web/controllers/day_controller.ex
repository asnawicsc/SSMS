defmodule SchoolWeb.DayController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Day

  def index(conn, _params) do
    day = Affairs.list_day()
    render(conn, "index.html", day: day)
  end

  def default_day(conn, params) do
    Repo.delete_all(Day)
    Affairs.create_day(%{name: "Sunday", number: 1})
    Affairs.create_day(%{name: "Monday", number: 2})
    Affairs.create_day(%{name: "Tuesday", number: 3})
    Affairs.create_day(%{name: "Wednesday", number: 4})
    Affairs.create_day(%{name: "Thursday", number: 5})
    Affairs.create_day(%{name: "Friday", number: 6})
    Affairs.create_day(%{name: "Saturday", number: 7})

    day = Affairs.list_day()

    conn
    |> put_flash(:info, "Day update successfully.")
    |> redirect(to: day_path(conn, :index, day))
  end

  def new(conn, _params) do
    changeset = Affairs.change_day(%Day{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"day" => day_params}) do
    case Affairs.create_day(day_params) do
      {:ok, day} ->
        conn
        |> put_flash(:info, "Day created successfully.")
        |> redirect(to: day_path(conn, :show, day))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    day = Affairs.get_day!(id)
    render(conn, "show.html", day: day)
  end

  def edit(conn, %{"id" => id}) do
    day = Affairs.get_day!(id)
    changeset = Affairs.change_day(day)
    render(conn, "edit.html", day: day, changeset: changeset)
  end

  def update(conn, %{"id" => id, "day" => day_params}) do
    day = Affairs.get_day!(id)

    case Affairs.update_day(day, day_params) do
      {:ok, day} ->
        conn
        |> put_flash(:info, "Day updated successfully.")
        |> redirect(to: day_path(conn, :show, day))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", day: day, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    day = Affairs.get_day!(id)
    {:ok, _day} = Affairs.delete_day(day)

    conn
    |> put_flash(:info, "Day deleted successfully.")
    |> redirect(to: day_path(conn, :index))
  end
end
