defmodule SchoolWeb.PageController do
  use SchoolWeb, :controller
  require IEx

  def index(conn, _params) do
    current_sem =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where: s.end_date > ^Timex.today() and s.start_date < ^Timex.today()
        )
      )

    if current_sem != [] do
      current_sem = hd(current_sem)
    else
      current_sem = %{start_date: "Not set", end_date: "Not set"}
    end

    render(conn, "index.html", current_sem: current_sem)
  end

  def dashboard(conn, _params) do
    current_sem =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where: s.end_date > ^Timex.today() and s.start_date < ^Timex.today()
        )
      )

    if current_sem != [] do
      current_sem = hd(current_sem)
    else
      current_sem = %{start_date: "Not set", end_date: "Not set"}
    end

    render(conn, "index.html", current_sem: current_sem)
  end

  def operations(conn, params) do
    uri = "https://www.li6rary.net/api"
    lib_id = School.Affairs.inst_id(conn)

    case params["scope"] do
      "get_lib" ->
        path = "?scope=get_lib&lib_id=#{lib_id}"

      "get_loans" ->
        path = "?scope=get_loans&lib_id=#{lib_id}"

      "get_books" ->
        cat_id = params["cat_id"]
        path = "?scope=get_books&cat_id=#{cat_id}&lib_id=#{lib_id}"
    end

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    send_resp(conn, 200, response)
  end

  def api(request_scope) do
    # uri<>"?scope=get_lib&lib_id=1",
    # uri<>"?scope=get_books&cat_id=3&lib_id=1",
    # uri<>"?scope=get_members&lib_id=1",

    # uri<>"?scope=link_member&lib_id=1",
    # uri<>"?scope=loan_book&lib_id=1",
    # uri<>"?scope=return_loan&lib_id=1",
  end
end
