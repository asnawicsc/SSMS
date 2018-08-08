defmodule SchoolWeb.TimePeriodController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TimePeriod

  def index(conn, _params) do
    time_period = Affairs.list_time_period()
    render(conn, "index.html", time_period: time_period)
  end

  def new(conn, _params) do
    changeset = Affairs.change_time_period(%TimePeriod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"time_period" => time_period_params}) do
    case Affairs.create_time_period(time_period_params) do
      {:ok, time_period} ->
        conn
        |> put_flash(:info, "Time period created successfully.")
        |> redirect(to: time_period_path(conn, :show, time_period))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    time_period = Affairs.get_time_period!(id)
    render(conn, "show.html", time_period: time_period)
  end

  def edit(conn, %{"id" => id}) do
    time_period = Affairs.get_time_period!(id)
    changeset = Affairs.change_time_period(time_period)
    render(conn, "edit.html", time_period: time_period, changeset: changeset)
  end

  def update(conn, %{"id" => id, "time_period" => time_period_params}) do
    time_period = Affairs.get_time_period!(id)

    case Affairs.update_time_period(time_period, time_period_params) do
      {:ok, time_period} ->
        conn
        |> put_flash(:info, "Time period updated successfully.")
        |> redirect(to: time_period_path(conn, :show, time_period))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", time_period: time_period, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    time_period = Affairs.get_time_period!(id)
    {:ok, _time_period} = Affairs.delete_time_period(time_period)

    conn
    |> put_flash(:info, "Time period deleted successfully.")
    |> redirect(to: time_period_path(conn, :index))
  end
end
