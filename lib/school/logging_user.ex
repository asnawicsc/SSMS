defmodule School.LoggingUser do
  import Plug.Conn
  import Phoenix.Controller
  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    cond do
      conn.private.plug_session["user_id"] == nil ->
        if conn.request_path == "/" or conn.request_path == "/contacts_us" or
             conn.request_path == "/authenticate" or conn.request_path == "/redirect_from_li6" or
             conn.request_path == "/parent_login" or conn.request_path == "/fb_login" or
             conn.request_path == "/validate_code" or conn.request_path == "/parents_corner" do
          conn
        else
          conn
          |> redirect(to: "/")
          |> halt
        end

      true ->
        conn
    end
  end
end
