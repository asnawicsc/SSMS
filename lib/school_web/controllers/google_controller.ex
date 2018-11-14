defmodule SchoolWeb.GoogleController do
  use SchoolWeb, :controller
  require IEx

  # open a page for google login or straight

  def open_google_oauth(conn, params) do
    uri = "https://accounts.google.com/o/oauth2/v2/auth"

    path = ""

    json_body = Poison.encode!()

    response =
      HTTPoison.request!(
        :post,
        uri <> path,
        json_body,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    IO.inspect(response)
    send_resp(conn, 200, response)
  end
end
