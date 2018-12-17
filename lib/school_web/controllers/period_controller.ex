defmodule SchoolWeb.PeriodController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Period
  alias School.Affairs.Class
  alias School.Affairs.Day
  alias School.Affairs.Teacher
  alias School.Affairs.Subject
  require IEx

  def index(conn, _params) do
    period = Affairs.get_inst_id(conn) |> Affairs.get_periods()

    render(conn, "index.html", period: period)
  end

  def new(conn, _params) do
    changeset = Affairs.change_period(%Period{})
    render(conn, "new.html", changeset: changeset)
  end

  def create_period(conn, params) do
    class_name = params["class"]
    subject = params["subject"]
    day = params["day"]
    end_time = params["end_time"] |> String.reverse()
    start_time = params["start_time"] |> String.reverse()
    teacher = params["teacher"]

    a = "00:"
    new_end_time = (a <> end_time) |> String.reverse() |> Time.from_iso8601!()
    new_start_time = (a <> start_time) |> String.reverse() |> Time.from_iso8601!()

    n_time = new_start_time.hour
    n_sm = new_start_time.minute
    e_time = new_end_time.hour
    n_em = new_start_time.minute

    if n_time == 0 do
      n_time = 12
    end

    if e_time == 0 do
      e_time = 12
    end

    subject = Repo.get_by(Subject, code: subject)
    class = Repo.get_by(Class, name: class_name)
    teacher = Repo.get_by(Teacher, code: teacher)

    params = %{
      day: day,
      end_time: new_end_time,
      start_time: new_start_time,
      teacher_id: teacher.id,
      class_id: class.id,
      subject_id: subject.id
    }

    period_class = Repo.all(from(p in Period, where: p.class_id == ^class.id and p.day == ^day))

    all =
      for item <- period_class do
        e = item.end_time.hour
        s = item.start_time.hour
        em = item.end_time.minute
        sm = item.start_time.minute

        if e == 0 do
          e = 12
        end

        if s == 0 do
          s = 12
        end

        %{end_time: e, start_time: s, start_minute: sm, end_minute: em}
      end

    a =
      all
      |> Enum.filter(fn x ->
        x.start_time >= n_time and x.start_time <= e_time and x.start_minute >= n_sm and
          x.start_minute <= n_em
      end)

    b = a |> Enum.count()

    if b == 0 do
      changeset = Affairs.change_period(%Period{})

      case Affairs.create_period(params) do
        {:ok, period} ->
          conn
          |> put_flash(:info, "Period created successfully.")
          |> redirect(to: subject_path(conn, :standard_setting))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:info, "That slot already been taken,please refer to period table.")
      |> redirect(to: subject_path(conn, :standard_setting))
    end
  end

  def get_create_period(conn, params) do
    {:ok, period} =
      Affairs.create_period(%{subject_id: params["subject_id"], class_id: params["class_id"]})

    conn
    |> put_flash(:info, "Period created successfully.")
    |> redirect(to: subject_teach_class_path(conn, :index))
  end

  def create(conn, %{"period" => period_params}) do
    case Affairs.create_period(period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period created successfully.")
        |> redirect(to: period_path(conn, :show, period))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    period = Affairs.get_period!(id)
    render(conn, "show.html", period: period)
  end

  def edit(conn, %{"id" => id}) do
    period = Affairs.get_period!(id)

    subject = Repo.get_by(Subject, id: period.subject_id)
    class = Repo.get_by(Class, id: period.class_id)
    teacher = Repo.get_by(Teacher, id: period.teacher_id)

    start_time = period.start_time |> Time.to_string() |> String.split_at(5) |> elem(0)
    end_time = period.end_time |> Time.to_string() |> String.split_at(5) |> elem(0)

    changeset = Affairs.change_period(period)

    render(
      conn,
      "edit.html",
      period: period,
      changeset: changeset,
      start_time: start_time,
      end_time: end_time,
      subject: subject,
      class: class,
      teacher: teacher
    )
  end

  def edit_event(conn, %{"period_id" => id}) do
    period = Affairs.get_period!(id)

    subject = Repo.get_by(Subject, id: period.subject_id)
    class = Repo.get_by(Class, id: period.class_id)
    teacher = Repo.get_by(Teacher, id: period.teacher_id)

    changeset = Affairs.change_period(period)

    render(
      conn,
      "edit.html",
      period: period,
      changeset: changeset,
      subject: subject,
      class: class,
      teacher: teacher
    )
  end

  def update(conn, %{"id" => id, "period" => period_params}) do
    period = Affairs.get_period!(id)

    case Affairs.update_period(period, period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period updated successfully.")
        |> redirect(to: period_path(conn, :show, period))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", period: period, changeset: changeset)
    end
  end

  def update_period(conn, params) do
    period = Repo.get(Period, params["id"])
    start_datetime = stringdatetime(params["start_datetime"])
    end_datetime = stringdatetime(params["end_datetime"])
    period_params = %{start_datetime: start_datetime, end_datetime: end_datetime}

    if period.master_period_id != nil do
      periods = all_child_periods(period.master_period_id, start_datetime)

      days_diff = Timex.diff(start_datetime, period.start_datetime, :days)

      for new_period <- periods do
        a = Time.new(start_datetime.hour, start_datetime.minute, 0) |> elem(1)

        c = Time.new(end_datetime.hour, end_datetime.minute, 0) |> elem(1)

        new_start_datetime =
          NaiveDateTime.new(
            Timex.shift(DateTime.to_date(new_period.start_datetime), days: days_diff),
            a
          )
          |> elem(1)
          |> DateTime.from_naive!("Etc/UTC")

        new_end_datetime =
          NaiveDateTime.new(
            Timex.shift(DateTime.to_date(new_period.end_datetime), days: days_diff),
            c
          )
          |> elem(1)
          |> DateTime.from_naive!("Etc/UTC")

        Affairs.update_period(new_period, %{
          start_datetime: new_start_datetime,
          end_datetime: new_end_datetime
        })

        School.Affairs.create_sync_list(%{period_id: new_period.id})
      end
    else
      if params["recurring_event"] == "on" do
        until_datetime = stringdatetime(params["until"])
        create_recurring_event(period, params["recurring_frequency"], until_datetime)
      end
    end

    # if this event has a master event,
    # from the master event, update the child events after this current event's date, 
    # and then update all the child event, 
    # and then flag for update..

    b = 0
    url = class_path(conn, :class_setting)

    link = url <> "/#{params["class_id"]}/modify_timetable"

    conn
    |> put_flash(:info, "Period deleted successfully.")

    if b == 0 do
      case Affairs.update_period(period, period_params) do
        {:ok, period} ->
          conn
          |> put_flash(:info, "Period updated successfully.")
          |> redirect(external: link)
      end
    else
      conn
      |> put_flash(:info, "That slot already been taken,please refer to period table.")
      |> redirect(external: link)
    end
  end

  def all_child_periods(master_period_id, start_datetime) do
    Repo.all(
      from(
        p in Period,
        where: p.master_period_id == ^master_period_id and p.start_datetime > ^start_datetime
      )
    )
  end

  def create_recurring_event(period, frequency, until_datetime) do
    # create the intervals(N), loop how many times, got how many weeks, determine N
    # create new events with same details, just different start end time
    rg = Date.range(DateTime.to_date(period.start_datetime), DateTime.to_date(until_datetime))
    no_days = Enum.count(rg)

    no_weeks = (no_days / 7) |> Float.floor() |> :erlang.trunc()

    case frequency do
      "daily" ->
        no_times = 1..no_days

        for new_date <- no_times do
          Affairs.create_period(%{
            class_id: period.class_id,
            end_datetime: Timex.shift(period.end_datetime, days: new_date),
            start_datetime: Timex.shift(period.start_datetime, days: new_date),
            master_period_id: period.id,
            subject_id: period.subject_id,
            teacher_id: period.teacher_id,
            timetable_id: period.timetable_id
          })
        end

      "weekly" ->
        # so i need to create 5 more events... 
        no_times = 1..no_weeks
        new_dates = Enum.map(no_times, fn x -> x * 7 end)

        for new_date <- new_dates do
          Affairs.create_period(%{
            class_id: period.class_id,
            end_datetime: Timex.shift(period.end_datetime, days: new_date),
            start_datetime: Timex.shift(period.start_datetime, days: new_date),
            master_period_id: period.id,
            subject_id: period.subject_id,
            teacher_id: period.teacher_id,
            timetable_id: period.timetable_id
          })
        end

      "monthly" ->
        true
    end

    Affairs.update_period(period, %{master_period_id: period.id})
  end

  def stringdatetime(datetime) do
    [sdate, stime] = datetime |> String.trim() |> String.split(" ")
    [y, m, d] = sdate |> String.split("-") |> Enum.map(fn x -> String.to_integer(x) end)
    sdate = Date.new(y, m, d) |> elem(1)

    [h, m, s] =
      stime
      |> String.split(":")
      |> List.insert_at(2, "00")
      |> Enum.map(fn x -> String.to_integer(x) end)

    stime = Time.new(h, m, s) |> elem(1)

    NaiveDateTime.new(sdate, stime)
    |> elem(1)
    |> DateTime.from_naive!("Etc/UTC")
    |> Timex.shift(hours: -8)
  end

  def delete(conn, %{"id" => id, "class_id" => class_id}) do
    period = Affairs.get_period!(id)

    {:ok, _period} = Affairs.delete_period(period)

    url = class_path(conn, :class_setting)

    link = url <> "/#{class_id}/modify_timetable"

    conn
    |> put_flash(:info, "Period deleted successfully.")
    |> redirect(external: link)
  end
end
