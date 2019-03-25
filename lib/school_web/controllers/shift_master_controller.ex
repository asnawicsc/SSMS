defmodule SchoolWeb.ShiftMasterController do
  use SchoolWeb, :controller
  require IEx
  alias School.Affairs
  alias School.Affairs.ShiftMaster

  def index(conn, _params) do
    shift_master = Affairs.list_shift_master()
    render(conn, "index.html", shift_master: shift_master)
  end

  def new(conn, _params) do
    changeset = Affairs.change_shift_master(%ShiftMaster{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shift_master" => shift_master_params}) do
    case Affairs.create_shift_master(shift_master_params) do
      {:ok, shift_master} ->
        conn
        |> put_flash(:info, "Shift master created successfully.")
        |> redirect(to: shift_master_path(conn, :show, shift_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create_shift(conn, params) do
    shift_master = Affairs.list_shift_master()

    render(conn, "create_shift.html", shift_master: shift_master)
  end

  def create_shift_master(conn, params) do
    name = params["name"]
    start_time = params["start_time"]
    end_time = params["end_time"]
    select_day = params["select_day"]

    count = select_day |> Enum.count()

    list_day =
      if count > 1 do
        select_day |> Enum.join(",")
      else
        select_day |> hd
      end

    shift_master_params = %{
      name: name,
      start_time: start_time,
      end_time: end_time,
      day: list_day,
      semester_id: conn.private.plug_session["semester_id"],
      institution_id: conn.private.plug_session["institution_id"]
    }

    Affairs.create_shift_master(shift_master_params)

    conn
    |> put_flash(:info, "Shift master created successfully.")
    |> redirect(to: shift_master_path(conn, :create_shift))
  end

  def assign_shift(conn, params) do
    teacher =
      Repo.all(
        from(s in School.Affairs.Teacher,
          left_join: r in School.Affairs.Shift,
          on: r.teacher_id == s.id,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            id: s.id,
            name: s.name,
            cname: s.name,
            code: s.code,
            shift_id: r.shift_master_id
          }
        )
      )
      |> Enum.uniq()

    shifts = Affairs.list_shift_master()

    render(conn, "assign_shift.html", teacher: teacher, shifts: shifts)
  end

  def create_teacher_shift(conn, params) do
    for item <- params["shift"] do
      teacher_id = item |> elem(0)
      shift_master_id = item |> elem(1)

      exist = Repo.get_by(School.Affairs.Shift, teacher_id: teacher_id)

      if exist != nil do
        Affairs.update_shift(exist, %{teacher_id: teacher_id, shift_master_id: shift_master_id})
      else
        Affairs.create_shift(%{teacher_id: teacher_id, shift_master_id: shift_master_id})
      end
    end

    conn
    |> put_flash(:info, "Shift assign successfully.")
    |> redirect(to: shift_master_path(conn, :create_shift))
  end

  def show(conn, %{"id" => id}) do
    shift_master = Affairs.get_shift_master!(id)
    render(conn, "show.html", shift_master: shift_master)
  end

  def edit(conn, %{"id" => id}) do
    shift_master = Affairs.get_shift_master!(id)
    changeset = Affairs.change_shift_master(shift_master)
    render(conn, "edit.html", shift_master: shift_master, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shift_master" => shift_master_params}) do
    shift_master = Affairs.get_shift_master!(id)

    case Affairs.update_shift_master(shift_master, shift_master_params) do
      {:ok, shift_master} ->
        conn
        |> put_flash(:info, "Shift master updated successfully.")
        |> redirect(to: shift_master_path(conn, :show, shift_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", shift_master: shift_master, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shift_master = Affairs.get_shift_master!(id)
    {:ok, _shift_master} = Affairs.delete_shift_master(shift_master)

    conn
    |> put_flash(:info, "Shift master deleted successfully.")
    |> redirect(to: shift_master_path(conn, :index))
  end
end
