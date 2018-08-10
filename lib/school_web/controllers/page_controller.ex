defmodule SchoolWeb.PageController do
  use SchoolWeb, :controller
  require IEx
  use Task
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

      "get_return_response" ->
        loan_id = params["loan_id"]
        path = "?scope=get_return_response&loan_id=#{loan_id}&lib_id=#{lib_id}"
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

  def upload_books(conn, params) do
    inst = Repo.get(Institution, School.Affairs.inst_id(conn))

    if Application.get_env(:your_app, :env) == nil do
      uri = "http://localhost:4000/api"
    else
      uri = "https://www.li6rary.net/api"
    end

    lib_id = inst.library_organization_id

    book_params = conn.params["book"]
    data = File.read!(book_params.path)
    data_list = data |> String.split("\n")

    header =
      data_list |> hd() |> String.split(",")
      |> Enum.map(fn x -> String.trim(String.downcase(x)) end)

    body = data_list |> tl()
    Task.start_link(__MODULE__, :upload_process, [body, header, lib_id, uri])

    conn
    |> put_flash(:info, "Library books uploaded!")
    |> redirect(to: page_path(conn, :books))
  end

  def upload_process(body, header, lib_id, uri) do
    for book_string <- body do
      book_data = book_string |> String.split(",")
      book_param = Enum.zip(header, book_data) |> Enum.into(%{})
      upload_book(book_param, lib_id, uri)
    end
  end

  def upload_book(book_param, lib_id, uri) do
    # new_pm
    book_param = Map.put(book_param, "lib_id", lib_id)
    book_param = Map.put(book_param, "scope", "upload_book")

    HTTPoison.request(
      :post,
      uri,
      Poison.encode!(book_param),
      [{"Content-Type", "application/json"}],
      []
    )
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

  def return(conn, params) do
    if Application.get_env(:your_app, :env) == nil do
      uri = "http://localhost:4000/api"
    else
      uri = "https://www.li6rary.net/api"
    end

    inst = Repo.get(Institution, School.Affairs.inst_id(conn))
    path = "?scope=get_returns&lib_id=#{inst.library_organization_id}"

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    returns = response |> Poison.decode!()

    render(conn, "return.html", returns: returns)
  end
end
