defmodule SchoolWeb.GoogleController do
  use SchoolWeb, :controller
  require IEx

  # open a page for google login or straight

  def open_google_oauth(conn, params) do
    uri = "https://accounts.google.com/o/oauth2/v2/auth"
    path = ""
    client_id = "233842430896-8badu1pcosa4q8butfr90fscjh0i5u3d.apps.googleusercontent.com"
    redirect_uri = "https://www.5chool.net/api/callback"

    scope =
      "https://www.googleapis.com/auth/calendar&https://www.googleapis.com/auth/calendar.events"

    access_type = "online"
    state = conn.query_string |> String.replace("&", ",")

    json_body = Poison.encode!(%{})

    url =
      "#{uri}?scope=#{scope}&access_type=#{access_type}&include_granted_scopes=true&state=#{state}&redirect_uri=#{
        redirect_uri
      }&response_type=code&client_id=#{client_id}"

    conn
    |> redirect(external: url)
  end

  def callback(conn, params) do
    IO.inspect(params)
    message = "Nothing happened."

    if params["error"] != nil do
      # redirect them back to the login page or back to their resources...
    else
      state =
        params["state"]
        |> String.split(",")
        |> Enum.map(fn x -> String.split(x, "=") end)
        |> Enum.map(fn x -> List.to_tuple(x) end)
        |> Enum.into(%{})

      code = params["code"]

      client_id = "233842430896-8badu1pcosa4q8butfr90fscjh0i5u3d.apps.googleusercontent.com"
      client_secret = "oQ1CRQ1nFSgYMsrmglzYUNo5"
      redirect_uri = "https://www.5chool.net/api/callback"

      # from the state can identify which institution and user id... then from the response below to save the access_token
      body = %{
        code: code,
        client_id: client_id,
        client_secret: client_secret,
        redirect_uri: redirect_uri,
        grant_type: "authorization_code",
        access_type: "online"
      }

      json_body = Poison.encode!(body)

      response =
        HTTPoison.request!(
          :post,
          "https://www.googleapis.com/oauth2/v4/token",
          json_body,
          [{"Content-Type", "application/json"}],
          timeout: 50_000,
          recv_timeout: 50_000
        ).body

      new_params = response |> Poison.decode!()
      IO.inspect(new_params)
      at = new_params["access_token"]
      rf = new_params["refresh_token"]
      # ["user_id", id] = params["state"] |> String.split("=")
      user =
        if state["user_id"] != nil do
          a = School.Settings.get_user!(state["user_id"])

          School.Settings.update_user(a, %{g_token: at})
          a
        end

      if state["request"] == "create_calendar" do
        calendar_id = create_calendar(state, at)
        sync_calendar_events(calendar_id, user.id, at)
      end

      # whatever the response go back to main page first
    end

    conn
    |> redirect(to: page_path(conn, :dashboard))
  end

  def sync_calendar_events(calendar_id, user_id, at) do
    # find the difference between 2 list

    # local list
    {:ok, teacher} = School.Affairs.get_teacher(user_id)
    local_list = School.Affairs.teacher_period_list(teacher.id)
    # google list
    google_list = School.Google.get_events(user_id)
    # each of the local list, create the events

    for local <- local_list do
      create_event(calendar_id, local, at)
    end
  end

  def create_event(calendar_id, local, at) do
    body =
      Map.put(local, :start, %{dateTime: DateTime.to_iso8601(Timex.shift(local.start, hours: -8))})

    body =
      Map.put(local, :end, %{dateTime: DateTime.to_iso8601(Timex.shift(local.end, hours: -8))})

    body = Map.put(local, :summary, local.title)
    json_body = Poison.encode!(body)

    response =
      HTTPoison.request!(
        :post,
        "https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events",
        json_body,
        [
          {"Authorization", "Bearer #{at}"},
          {"Accept", "application/json"},
          {"Content-Type", "application/json"}
        ],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    event_params = response |> Poison.decode!()

    google_event_id = event_params["id"]
    period = School.Affairs.get_period!(local.period_id)
    a = School.Affairs.update_period(period, %{google_event_id: google_event_id})
    IO.inspect(event_params)
    IO.inspect(a)
  end

  def create_calendar(state, at) do
    a = School.Settings.get_user!(state["user_id"])

    body = %{
      summary: a.name <> "@5chool.net teacher calendar",
      access_token: at
    }

    json_body = Poison.encode!(body)

    response =
      HTTPoison.request!(
        :post,
        "https://www.googleapis.com/calendar/v3/calendars",
        json_body,
        [
          {"Authorization", "Bearer #{at}"},
          {"Accept", "application/json"},
          {"Content-Type", "application/json"}
        ],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    calendar_params = response |> Poison.decode!()
    calendar_id = calendar_params["id"]

    case School.Affairs.get_teacher(state["user_id"]) do
      {:ok, teacher} ->
        {:ok, timetable} = School.Affairs.initialize_calendar(teacher.id)
        School.Affairs.update_timetable(timetable, %{calender_id: calendar_id})

      _ ->
        true
    end

    calendar_id
  end
end
