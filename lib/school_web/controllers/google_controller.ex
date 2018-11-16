defmodule SchoolWeb.GoogleController do
  use SchoolWeb, :controller
  require IEx

  # open a page for google login or straight

  def open_google_oauth(conn, params) do
    uri = "https://accounts.google.com/o/oauth2/v2/auth"

    path = ""
    client_id = "233842430896-8badu1pcosa4q8butfr90fscjh0i5u3d.apps.googleusercontent.com"
    redirect_uri = "https://www.5chool.net/api/callback"
    scope = "https://www.googleapis.com/auth/calendar"
    access_type = "online"
    state = conn.query_string

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

    if params["error"] != nil do
      # redirect them back to the login page or back to their resources...
    else
      code = params["code"]

      client_id = "233842430896-8badu1pcosa4q8butfr90fscjh0i5u3d.apps.googleusercontent.com"
      client_secret = "oQ1CRQ1nFSgYMsrmglzYUNo5"
      redirect_uri = "https://www.5chool.net/api/callback"
      scope = "https://www.googleapis.com/auth/calendar"
      access_type = "online"

      # from the state can identify which institution and user id... then from the response below to save the access_token
      json_body =
        Poison.encode!(%{
          code: code,
          client_id: client_id,
          client_secret: client_secret,
          redirect_uri: redirect_uri,
          grant_type: "authorization_code"
        })

      response =
        HTTPoison.request!(
          :post,
          "https://www.googleapis.com/oauth2/v4/token",
          json_body,
          [{"Content-Type", "application/json"}],
          timeout: 50_000,
          recv_timeout: 50_000
        ).body

      IO.inspect(response)
      new_params = response |> Poison.decode!()
      at = params["access_token"]
      # whatever the response go back to main page first
    end

    conn
    |> redirect(to: page_path(conn, :dashboard))
  end
end

# uri = "https://www.googleapis.com/calendar/v3/calendars/#{cal_id}/events?access_token=#{access_token}"
# response = HTTPoison.get!(uri, [], timeout: 10_000, recv_timeout: 10_000).body
