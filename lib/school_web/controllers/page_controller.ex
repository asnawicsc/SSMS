defmodule SchoolWeb.PageController do
  use SchoolWeb, :controller
  require IEx
  alias School.Settings.Institution

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
    inst = Repo.get(Institution, School.Affairs.inst_id(conn))

    if Application.get_env(:your_app, :env) == nil do
      uri = "http://localhost:4000/api"
    else
      uri = "https://www.li6rary.net/api"
    end

    lib_id = inst.library_organization_id

    case params["scope"] do
      "get_loans" ->
        path = "?scope=get_loans&lib_id=#{lib_id}"

      "get_books" ->
        cat_id = params["cat_id"]
        path = "?scope=get_books&cat_id=#{cat_id}&lib_id=#{lib_id}"

      "get_book" ->
        query = params["query"]
        path = "?scope=get_book&query=#{query}&lib_id=#{lib_id}"

      "get_user" ->
        query = params["query"]
        path = "?scope=get_user&query=#{query}&lib_id=#{lib_id}"

      "get_loan_response" ->
        book = params["book"]
        user = params["user"]
        path = "?scope=get_loan_response&book=#{book}&user=#{user}&lib_id=#{lib_id}"
    end

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    IO.inspect(response)
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

  def books(conn, params) do
    if Application.get_env(:your_app, :env) == nil do
      uri = "http://localhost:4000/api"
      lib_id = 3
    else
      uri = "https://www.li6rary.net/api"
      lib_id = School.Affairs.inst_id(conn)
    end

    path = "?scope=get_lib&inst_id=sa_#{lib_id}"

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    library = response |> Poison.decode!()

    library_organization_id = library["org_id"]
    inst = Repo.get(Institution, School.Affairs.inst_id(conn))

    Institution.changeset(inst, %{library_organization_id: library_organization_id})
    |> Repo.update()

    loan = library["loan"]
    categories = library["categories"]

    render(conn, "books.html", loans: loan, categories: categories)
  end

  def new_loan(conn, params) do
    render(conn, "new_loan.html")
  end
end
