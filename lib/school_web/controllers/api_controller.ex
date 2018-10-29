defmodule SchoolWeb.ApiController do
  use SchoolWeb, :controller
  use Task
  import Ecto.Query
  alias School.Settings
  alias School.Settings.{Institution, User, Parameter}
  require IEx

  def webhook_post_operations(conn, params) do
    IO.inspect(params)

    cond do
      params["scope"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"scope", "scope value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include scope.")

      params["key"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"api key", "key value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include key .")

      params["code"] == nil ->
        message =
          List.insert_at(conn.req_headers, 0, {"institution_id", "institution_id value is empty"})

        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include code .")

      params["code"] != nil and params["key"] != nil and params["scope"] != nil ->
        institution =
          Repo.get_by(Institution,
            institution_id: params["institution_id"],
            api_key: params["key"]
          )

        if institution != nil do
          case params["scope"] do
            "student_list" ->
              push_student_list(conn, params, institution)

            _ ->
              send_resp(conn, 500, "requested scope not available. \n")
          end
        else
          cond do
            institution == nil ->
              message =
                List.insert_at(
                  conn.req_headers,
                  0,
                  {"authentication", "code and key doesnt match"}
                )

              log_error_api(message, params["code"] <> " API POST -" <> params["scope"])
              send_resp(conn, 400, "User not found.")

            true ->
              message = List.insert_at(conn.req_headers, 0, {"authentication", "unknown"})
              log_error_api(message, params["code"] <> " API POST -" <> params["scope"])
              send_resp(conn, 400, "user credentials are incorrect.")
          end
        end

      true ->
        send_resp(conn, 500, "please contact system admin. \n")
    end
  end

  def push_student_list(conn, params, institution) do
    params = Map.put(params, "institution_id", institution.id)
    # post the cash in cash out shits...
    cg = BoatNoodle.BN.Students.changeset(%BoatNoodle.BN.Student{}, params)

    case Repo.insert(cg) do
      {:ok, ci} ->
        Task.start_link(__MODULE__, :log_api, [
          IO.inspect(ci),
          params["code"] <> " API POST -" <> params["scope"]
        ])

        map = %{status: "ok"} |> Poison.encode!()
        send_resp(conn, 200, map)

      {:error, changeset} ->
        model_insert_error(conn, changeset, params)
        send_resp(conn, 500, "not ok")
    end
  end

  def webhook_get(conn, params) do
    cond do
      params["fields"] == nil ->
        send_resp(conn, 200, "please include request  in field.")

      params["fields"] == "get_student_list" ->
        get_student_list(params)
    end
  end

  def get_student_list(params) do
    messenger_user_id = params["messenger user id"]

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
