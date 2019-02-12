defmodule SchoolWeb.TimetableController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.Timetable
  alias School.Affairs.Subject
  alias School.Affairs.Class

  def index(conn, _params) do
    timetable = Affairs.list_timetable()
    render(conn, "index.html", timetable: timetable)
  end

  def new(conn, _params) do
    changeset = Affairs.change_timetable(%Timetable{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"timetable" => timetable_params}) do
    case Affairs.create_timetable(timetable_params) do
      {:ok, timetable} ->
        conn
        |> put_flash(:info, "Timetable created successfully.")
        |> redirect(to: timetable_path(conn, :show, timetable))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    timetable = Affairs.get_timetable!(id)
    render(conn, "show.html", timetable: timetable)
  end

  def edit(conn, %{"id" => id}) do
    timetable = Affairs.get_timetable!(id)
    changeset = Affairs.change_timetable(timetable)
    render(conn, "edit.html", timetable: timetable, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timetable" => timetable_params}) do
    timetable = Affairs.get_timetable!(id)

    case Affairs.update_timetable(timetable, timetable_params) do
      {:ok, timetable} ->
        conn
        |> put_flash(:info, "Timetable updated successfully.")
        |> redirect(to: timetable_path(conn, :show, timetable))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", timetable: timetable, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    timetable = Affairs.get_timetable!(id)
    {:ok, _timetable} = Affairs.delete_timetable(timetable)

    conn
    |> put_flash(:info, "Timetable deleted successfully.")
    |> redirect(to: timetable_path(conn, :index))
  end

  def class_timetable(conn, params) do
    events =
      case School.Affairs.get_class!(params["class_id"]) do
        class ->
          School.Affairs.class_period_list(class.id)

        {:error, message} ->
          []
      end
      |> Poison.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, events)
  end

  def teacher_timetable(conn, params) do
    events =
      case School.Affairs.get_teacher(params["user_id"]) do
        {:ok, teacher} ->
          {:ok, timetable} =
            School.Affairs.initialize_calendar(
              conn.private.plug_session["institution_id"],
              conn.private.plug_session["semester_id"],
              teacher.id
            )

          School.Affairs.teacher_period_list(teacher.id)

        {:error, message} ->
          []
      end
      |> Poison.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, events)
  end

  def sync_to_gcal(conn, params) do
    user = School.Settings.current_user(conn)

    case School.Affairs.get_teacher(params["user_id"]) do
      {:ok, teacher} ->
        {:ok, timetable} = School.Affairs.initialize_calendar(teacher.id)

        if timetable.calender_id == nil do
          conn
          |> redirect(
            to:
              google_path(conn, :open_google_oauth, user_id: user.id, request: "create_calendar")
          )
        else
          conn
          |> redirect(
            to: google_path(conn, :open_google_oauth, user_id: user.id, request: "sync_calendar")
          )
        end

      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect(to: timetable_path(conn, :index))
    end
  end

  def teacher_timetable_list(conn, params) do
    timetable_id = 0

    case School.Affairs.get_teacher(params["user_id"]) do
      {:ok, teacher} ->
        true

        {:ok, timetable} =
          School.Affairs.initialize_calendar(
            conn.private.plug_session["institution_id"],
            conn.private.plug_session["semester_id"],
            teacher.id
          )

        periods = Affairs.get_inst_id(conn) |> Affairs.get_periods()

        render(conn, "teacher_timetable_list.html", periods: periods)

      {:error, message} ->
        true

        conn
        |> put_flash(:info, message)
        |> redirect(to: timetable_path(conn, :index))
    end
  end

  def generated_timetable(conn, params) do
    changeset = Affairs.change_timetable(%Timetable{})
    class_id = params["id"]

    period =
      Repo.all(
        from(p in School.Affairs.Period,
          left_join: r in School.Affairs.Timetable,
          on: p.timetable_id == r.id,
          where:
            r.institution_id == ^conn.private.plug_session["institution_id"] and
              r.semester_id == ^conn.private.plug_session["semester_id"] and
              p.teacher_id == r.teacher_id and p.class_id == ^class_id,
          select: %{
            start_datetime: p.start_datetime,
            end_datetime: p.end_datetime,
            class_id: p.class_id,
            subject_id: p.subject_id,
            teacher_id: p.teacher_id
          }
        )
      )

    all2 =
      for item <- period do
        e = item.end_datetime.hour
        s = item.start_datetime.hour
        sm = item.start_datetime.minute
        em = item.end_datetime.minute

        e =
          if e == 0 do
            12
          else
            e
          end

        s =
          if s == 0 do
            12
          else
            s
          end

        date = DateTime.to_date(item.end_datetime)

        a = Timex.days_to_end_of_week(date)

        exact_date = 7 - a
        # IEx.pry()
        g = item.end_datetime.day
        subject = Repo.get_by(Subject, id: item.subject_id)

        %{
          location: exact_date,
          end_hour: e,
          end_minute: em,
          start_minute: sm,
          start_hour: s,
          name: subject.timetable_code
        }
      end
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.uniq()

    class = Repo.get_by(Class, id: params["id"])

    render(conn, "generated_timetable.html",
      all2: Poison.encode!(all2),
      class: class,
      period: period
    )
  end
end
