defmodule SchoolWeb.ApiController do
  use SchoolWeb, :controller
  use Task
  import Ecto.Query
  alias School.Settings
  alias School.Settings.{Institution, User, Parameter}
  require IEx

  def webhook_get(conn, params) do
    cond do
      params["fields"] == nil ->
        send_resp(conn, 200, "please include request  in field.")

      params["fields"] == "get_student_list" ->
        get_student_list(conn, params)
    end
  end

  def get_student_list(conn, params) do
    messenger_user_id = params["messenger user id"]
    ic = params["IC"]

    # parent = Repo.all(from(s in School.Affairs.Parent, where(s.icno == ^ic)))
    parent = Repo.all(from(s in School.Affairs.Parent, where: s.icno == ^ic))
    IO.inspect(params)
    uri = Application.get_env(:school, :api)[:url]

    {map} =
      if parent != [] do
        # students = Repo.all(from(s in School.Affairs.Student, where(s.gicno == ^ic)))
        students = Repo.all(from(s in School.Affairs.Student, where: s.gicno == ^ic))

        map =
          %{
            "messages" => [
              %{
                "attachment" => %{
                  "type" => "template",
                  "payload" => %{
                    "template_type" => "button",
                    "text" => "Please click on your children name.",
                    "buttons" => [
                      for stud <- students do
                        path = "?scope=get__stud=#{stud.id}"
                        name = stud.name

                        %{
                          "url" => uri <> path,
                          "type" => "json_plugin_url",
                          "title" => name
                        }
                      end
                    ]
                  }
                }
              }
            ]
          }
          |> Poison.encode!()

        {map}
      else
        map =
          %{
            "messages" => [
              %{"text" => "Sorry, we dont have your data!"},
              %{"text" => "Please contact admin, for more info. 🤖"}
            ]
          }
          |> Poison.encode!()

        {map}
      end

    send_resp(conn, 200, map)
  end

  def fb_login(conn, params) do
    redir_url = "https://www.5chool.net/validate_code"

    app_id = "2120429611555339"

    state_params = "sb=#{true}"

    url =
      "https://www.facebook.com/v3.0/dialog/oauth?client_id=#{app_id}&redirect_uri=#{redir_url}&state=#{
        state_params
      }&scope=email,public_profile"

    conn
    |> redirect(external: url)
  end

  def code(conn, params) do
    IO.puts("validating code...\n")

    # str8 app id
    # str8 app secret
    app_id = "2120429611555339"
    app_secret = "fad0fe09ce081738e2900f6b5eebcd7b"
    page_id = "340744706488937"
    redir_url = "https://www.5chool.net/validate_code"
    IO.inspect(params)

    code = conn.params["code"]

    uri2 =
      "https://graph.facebook.com/v3.0/oauth/access_token?client_id=#{app_id}&redirect_uri=#{
        redir_url
      }&client_secret=#{app_secret}&code=#{code}"

    response = HTTPoison.get!(uri2)
    body = response.body
    IO.puts(body)
    {:ok, map_first} = Poison.decode(body)
    access_token = map_first["access_token"]

    uri4 =
      "https://graph.facebook.com/v3.0/oauth/access_token?client_id=#{app_id}&client_secret=#{
        app_secret
      }&grant_type=client_credentials"

    response = HTTPoison.get!(uri4)
    body = response.body
    IO.puts(body)
    {:ok, map} = Poison.decode(body)

    page_access_token = map["access_token"]

    uri3 =
      "https://graph.facebook.com/debug_token?input_token=#{access_token}&access_token=#{
        page_access_token
      }"

    response = HTTPoison.get!(uri3)
    body = response.body
    IO.puts(body)
    {:ok, map_last} = Poison.decode(body)
    user_id = map_last["data"]["user_id"]

    if user_id == nil do
      conn
      |> put_flash(:info, "Facebook Login not available at the moment.")
      |> redirect(to: "/")
    else
      appsecret_proof = :crypto.hmac(:sha256, app_secret, page_access_token) |> Base.encode16()

      uri5 =
        "https://graph.facebook.com/#{user_id}/?fields=name,email,ids_for_apps,ids_for_pages&access_token=#{
          page_access_token
        }&appsecret_proof=#{appsecret_proof}"

      response = HTTPoison.get!(uri5)
      body = response.body
      IO.puts(body)
      {:ok, map_user} = Poison.decode(body)

      # here is where we start gathering data for the ids for apps, there is also a possibility where the user dont have data for the current fb app...
      # there is no psid, maybe didnt include the business manager for the page.
      # very likely there is a name in map_user 
      # just create this as a normal str8 user 
      IO.puts("checking for params state\n")

      IO.inspect(conn.params["state"])

      conn
      |> put_session(:user_id, user_id)
      |> put_flash(:info, "Logged in")
      |> redirect(to: "/dashboard")
    end
  end
end
