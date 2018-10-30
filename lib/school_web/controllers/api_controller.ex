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
    IO.inspect(params)
    uri = Application.get_env(:school, :api)[:url]

    map =
      %{
        "messages" => [
          %{
            "attachment" => %{
              "type" => "template",
              "payload" => %{
                "template_type" => "button",
                "buttons" => [
                  %{
                    "type" => "show_block",
                    "block_names" => ["name of block"],
                    "title" => "Show Block"
                  },
                  %{
                    "type" => "web_url",
                    "url" => uri,
                    "title" => "Visit Website"
                  },
                  %{
                    "set_attributes" => %{
                      "some attribute" => "some value",
                      "another attribute" => "another value"
                    },
                    "url" => uri,
                    "type" => "json_plugin_url",
                    "title" => "Postback"
                  }
                ]
              }
            }
          }
        ]
      }
      |> Poison.encode!()

    send_resp(conn, 200, map)
  end
end
