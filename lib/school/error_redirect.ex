defmodule School.ErrorRedirect do
  import Plug.Conn
  import Phoenix.Controller
  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    IEx.pry()

    conn
  end
end
