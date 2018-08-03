defmodule School.SetLocale do
  import Plug.Conn
  alias School.Repo
  alias School.Settings.User
  import Ecto.Query
  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    lang = "en"

    if conn.private.plug_session["user_id"] != nil do
      user = Repo.get(User, conn.private.plug_session["user_id"])
      lang = user.default_lang
    end

    Gettext.put_locale(SchoolWeb.Gettext, lang)
    conn
  end
end
