defmodule School.EmptySubdomain do
  import Plug.Conn
  import Phoenix.Controller
  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    host = SchoolWeb.Endpoint.config(:url)[:host] |> String.split(":") |> hd()

    cond do
      conn.host != host ->
        url = SchoolWeb.Endpoint.config(:url)[:host]

        conn
        |> redirect(external: "https://#{url}")

      true ->
        conn
    end
  end
end
