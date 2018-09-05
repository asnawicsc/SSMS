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

    current_sem =
      if current_sem != [] do
        hd(current_sem)
      else
        %{start_date: "Not set", end_date: "Not set"}
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

    current_sem =
      if current_sem != [] do
        hd(current_sem)
      else
        %{start_date: "Not set", end_date: "Not set"}
      end

    render(conn, "index.html", current_sem: current_sem)
  end

  def operations(conn, params) do
    inst = Repo.get(Institution, School.Affairs.inst_id(conn))
    uri = Application.get_env(:school, :api)[:url]
    # uri = "https://www.li6rary.net/api"

    lib_id = inst.library_organization_id

    {path} =
      case params["scope"] do
        "get_loans" ->
          {"?scope=get_loans&lib_id=#{lib_id}"}

        "get_books" ->
          cat_id = params["cat_id"]
          {"?scope=get_books&cat_id=#{cat_id}&lib_id=#{lib_id}"}

        "get_book" ->
          query = params["query"]

          {"?scope=get_book&query=#{query}&lib_id=#{lib_id}"}

        "get_user" ->
          query = params["query"]
          {"?scope=get_user&query=#{query}&lib_id=#{lib_id}"}

        "get_loan_response" ->
          book = params["book"]
          user = params["user"]
          {"?scope=get_loan_response&book=#{book}&user=#{user}&lib_id=#{lib_id}"}

        "get_return_response" ->
          loan_id = params["loan_id"]

          {"?scope=get_return_response&loan_id=#{loan_id}&lib_id=#{lib_id}"}

        "get_book_inventory" ->
          query = params["b_id"]

          {"?scope=get_book_inventory&query=#{query}&lib_id=#{lib_id}"}
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

    # uri = "https://www.li6rary.net/api"
    uri = Application.get_env(:school, :api)[:url]

    lib_id = inst.library_organization_id

    book_params = conn.params["book"]
    data = File.read!(book_params.path)
    data_list = data |> String.split("\n")

    header =
      data_list
      |> hd()
      |> String.split(",")
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
    # uri = "https://www.li6rary.net/api"
    uri = Application.get_env(:school, :api)[:url]

    lib_id =
      if Application.get_env(:school, :env) == nil do
        lib_id = 3
      else
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
    # uri = "https://www.li6rary.net/api"
    uri = Application.get_env(:school, :api)[:url]

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

  def update_book(conn, params) do
    inst = Repo.get(Institution, School.Affairs.inst_id(conn))

    uri = Application.get_env(:school, :api)[:url]

    lib_id = inst.library_organization_id

    book_params = %{
      scope: "update_book",
      author: params["author"],
      id: params["id"],
      barcode: params["barcode"],
      coauthor: params["coauthor"],
      illustrator: params["illustrator"],
      isbn: params["isbn"],
      publisher: params["publisher"],
      series: params["series"],
      title: params["name"],
      translator: params["translator"],
      volume: params["volume"]
    }

    HTTPoison.request(
      :post,
      uri,
      Poison.encode!(book_params),
      [{"Content-Type", "application/json"}],
      []
    )

    conn
    |> put_flash(:info, "Library books updated!")
    |> redirect(to: page_path(conn, :books, cat_id: params["cat_id"], b_id: params["b_id"]))
  end

  def student_cards(conn, params) do
    uri = Application.get_env(:school, :api)[:url]

    inst = Repo.get(Institution, School.Affairs.inst_id(conn))
    path = "?scope=get_templates&lib_id=#{inst.library_organization_id}"
    # path = "?scope=get_templates&lib_id=3"

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

     templates = if response == "[]" do
     nil
    else
     response |> Poison.decode!() |> hd()
    end

    render(conn, "student_cards.html", templates: templates)
  end

  def update_template(conn, params) do
    inst = Repo.get(Institution, School.Affairs.inst_id(conn))

    uri = Application.get_env(:school, :api)[:url]

    lib_id = inst.library_organization_id

    template_params = %{
      scope: "update_template",
      front_bin: params["long"],
      back_bin: params["long2"],
      css_bin: params["styles"],
      organization_id: lib_id
    }

    HTTPoison.request(
      :post,
      uri,
      Poison.encode!(template_params),
      [{"Content-Type", "application/json"}],
      []
    )

    conn
    |> put_flash(:info, "Student Card design updated!")
    |> redirect(to: page_path(conn, :student_cards))
  end

  def generate_student_card(conn, params) do
    uri = Application.get_env(:school, :api)[:url]
    inst = Repo.get(Institution, School.Affairs.inst_id(conn))
    path = "?scope=get_templates&lib_id=#{inst.library_organization_id}"

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    template = response |> Poison.decode!() |> hd()

    lib_id = inst.library_organization_id
    student_ids = params["ids"] |> String.split("\r\n")

    map_list =
      for id <- student_ids do
        student = Repo.get_by(Student, student_no: id)
        f_bin = template["front_bin"]
        b_bin = template["back_bin"]

        # front bin
        f_bin = f_bin |> String.replace("_name_", student.name)
        f_bin = f_bin |> String.replace("_cname_", student.chinese_name)
        f_bin = f_bin |> String.replace("_stu_id_", student.student_no)
        f_bin = f_bin |> String.replace("_ic_)", student.ic)

        # back bin
        b_bin = b_bin |> String.replace("_name_", student.name)
        b_bin = b_bin |> String.replace("_cname_", student.chinese_name)
        b_bin = b_bin |> String.replace("_stu_id_", student.student_no)
        b_bin = b_bin |> String.replace("_ic_", student.ic)

        image_path = Application.app_dir(:school, "priv/static/images")

        Barlix.Code39.encode!(student.student_no)
        |> Barlix.PNG.print(file: image_path <> "/#{student.student_no}.png", xdim: 5)

        {:ok, bin} = File.read(image_path <> "/#{student.student_no}.png")

        image_bin = Base.encode64(bin)
        image_str = "<img style='width: 80%;' src='data:image/png;base64, #{image_bin}'>"

        File.rm!(image_path <> "/#{student.student_no}.png")

        f_bin = f_bin |> String.replace("_barcode_", image_str)
        b_bin = b_bin |> String.replace("_barcode_", image_str)

        map = %{contents: f_bin, styles: template["css_bin"], contents2: b_bin}
        map
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PageView,
        "show_card.html",
        contents: nil,
        styles: nil,
        contents2: nil,
        map_lists: map_list
      )

    # IEx.pry()
    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "1",
          "--margin-right",
          "1",
          "--margin-top",
          "1",
          "--margin-bottom",
          "1",
          "--encoding",
          "utf-8"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def preview_template(conn, params) do
    contents = params["long"]
    contents2 = params["long2"]
    styles = params["styles"]

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PageView,
        "show_card.html",
        contents: contents,
        styles: styles,
        contents2: contents2,
        map_lists: nil
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "1",
          "--margin-right",
          "1",
          "--margin-top",
          "1",
          "--margin-bottom",
          "1",
          "--encoding",
          "utf-8"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end
end
