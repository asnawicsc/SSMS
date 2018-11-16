defmodule School.Google do
  use Task
  import Ecto.Query
  require IEx

  alias School.Affairs

  def create_calendar(user_id) do
    user = School.Settings.get_user!(user_id)
    uri = "https://www.googleapis.com/calendar/v3/calendars"

    json_body =
      Poison.encode!(%{
        summary: "5chool.net calendar test",
        access_token: user.g_token
      })

    response =
      HTTPoison.request!(
        :post,
        uri,
        json_body,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    IO.inspect(response)

    {:ok}
  end

  def get_events(user_id) do
    {:ok, teacher} = Affairs.get_teacher(user_id)
    {:ok, timetable} = Affairs.initialize_calendar(teacher.id)
    user = School.Settings.get_user!(user_id)

    cal_id = timetable.calender_id

    uri =
      "https://www.googleapis.com/calendar/v3/calendars/#{cal_id}/events?access_token=#{
        user.g_token
      }"

    response =
      HTTPoison.get!(uri, [], timeout: 10_000, recv_timeout: 10_000).body |> Poison.decode!()

    IO.inspect(response)

    response["items"]
  end
end
