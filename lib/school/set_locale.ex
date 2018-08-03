defmodule School.SetLocale do
  import Plug.Conn

  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    Gettext.put_locale(SchoolWeb.Gettext, "my")
    conn
  end
end
