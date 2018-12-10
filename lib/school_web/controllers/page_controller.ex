defmodule SchoolWeb.PageController do
  use SchoolWeb, :controller
  require IEx
  use Task
  alias School.Settings.Institution

  def apply_color(conn, params) do
    user = Settings.current_user(conn)
    role = user.role

    location =
      case role do
        "Support" ->
          :support_dashboard

        "Admin" ->
          :admin_dashboard

        _ ->
          :dashboard
      end

    conn
    |> put_session(:style, user.styles)
    |> redirect(to: page_path(conn, location))
  end

  def redirect_from_li6(conn, params) do
    user = Repo.get_by(User, name: params["name"], email: params["email"])
    role = user.role

    location =
      case role do
        "Support" ->
          :support_dashboard

        "Admin" ->
          :admin_dashboard

        _ ->
          :dashboard
      end

    institution =
      Repo.get_by(
        Settings.Institution,
        library_organization_id: params["library_organization_id"]
      )

    current_sem =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where:
            s.end_date > ^Timex.today() and s.start_date < ^Timex.today() and
              s.institution_id == ^institution.id
        )
      )

    current_sem =
      if current_sem != [] do
        hd(current_sem)
      else
        %{id: 0, start_date: "Not set", end_date: "Not set"}
      end

    conn
    |> put_session(:user_id, user.id)
    |> put_session(:semester_id, current_sem.id)
    |> put_session(:institution_id, institution.id)
    |> redirect(to: page_path(conn, location))
  end

  def outstanding_all(conn, params) do
    # uri = "https://www.li6rary.net/api"
    uri = Application.get_env(:school, :api)[:url]

    inst = Repo.get(Institution, School.Affairs.inst_id(conn))
    loan_date = conn.params["loan_date"]
    return_date = conn.params["return_date"]

    path = "?scope=get_outstanding_all&lib_id=#{inst.library_organization_id}"

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    data =
      response
      |> Poison.decode!()

    loans =
      for data_o <- data do
        for {key, val} <- data_o, into: %{}, do: {String.to_atom(key), val}
      end

    loans =
      loans
      |> Enum.with_index()
      |> Enum.chunk_every(35)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "outstanding.html",
        loans: loans,
        conn: conn,
        organization: inst,
        loan_date: loan_date,
        return_date: return_date
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
          "utf-8",
          "--orientation",
          "Landscape"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def outstanding(conn, params) do
    # uri = "https://www.li6rary.net/api"
    uri = Application.get_env(:school, :api)[:url]

    inst = Repo.get(Institution, School.Affairs.inst_id(conn))
    loan_date = conn.params["loan_date"]
    return_date = conn.params["return_date"]

    path =
      "?scope=get_outstanding&lib_id=#{inst.library_organization_id}&loan_date=#{loan_date}&return_date=#{
        return_date
      }"

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    data =
      response
      |> Poison.decode!()

    loans =
      for data_o <- data do
        for {key, val} <- data_o, into: %{}, do: {String.to_atom(key), val}
      end

    loans =
      loans
      |> Enum.with_index()
      |> Enum.chunk_every(35)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "outstanding.html",
        loans: loans,
        conn: conn,
        organization: inst,
        loan_date: loan_date,
        return_date: return_date
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
          "utf-8",
          "--orientation",
          "Landscape"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def history_data(conn, params) do
    # uri = "https://www.li6rary.net/api"
    uri = Application.get_env(:school, :api)[:url]

    inst = Repo.get(Institution, School.Affairs.inst_id(conn))
    loan_date = conn.params["loan_date"]
    return_date = conn.params["return_date"]

    path =
      "?scope=get_history_data&lib_id=#{inst.library_organization_id}&loan_date=#{loan_date}&return_date=#{
        return_date
      }"

    response =
      HTTPoison.get!(
        uri <> path,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    data =
      response
      |> Poison.decode!()

    loans =
      for data_o <- data do
        for {key, val} <- data_o, into: %{}, do: {String.to_atom(key), val}
      end

    loans =
      loans
      |> Enum.with_index()
      |> Enum.chunk_every(35)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "loan_history.html",
        loans: loans,
        conn: conn,
        organization: inst,
        loan_date: loan_date,
        return_date: return_date
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
          "utf-8",
          "--orientation",
          "Landscape"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

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

  def index_splash(conn, _params) do
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

    render(conn, "index_splash.html", current_sem: current_sem)
  end

  def contacts_us(conn, _params) do
    render(conn, "contacts_us.html")
  end

  def loan_report(conn, _params) do
    render(conn, "loan_report.html", [])
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

    user = Settings.current_user(conn)
    role = user.role

    if role == "Parent" do
      conn
      |> redirect(to: parent_path(conn, :parents_corner))
    else
      location =
        case role do
          "Support" ->
            "support_page.html"

          "Admin" ->
            "admin_page.html"

          _ ->
            "index.html"
        end

      render(conn, location, current_sem: current_sem)
    end
  end

  def admin_dashboard(conn, _params) do
    current_sem =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where: s.end_date > ^Timex.today() and s.start_date < ^Timex.today()
        )
      )

    changeset = Settings.change_institution(%Institution{})

    current_sem =
      if current_sem != [] do
        hd(current_sem)
      else
        %{start_date: "Not set", end_date: "Not set"}
      end

    institution = Settings.list_institutions()

    users = Settings.list_users()

    render(
      conn,
      "admin_page.html",
      current_sem: current_sem,
      institution: institution,
      users: users,
      changeset: changeset
    )
  end

  def support_dashboard(conn, _params) do
    current_sem =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where: s.end_date > ^Timex.today() and s.start_date < ^Timex.today()
        )
      )

    changeset = Settings.change_institution(%Institution{})

    current_sem =
      if current_sem != [] do
        hd(current_sem)
      else
        %{start_date: "Not set", end_date: "Not set"}
      end

    institution = Settings.list_institutions()

    users = Settings.list_users()

    render(
      conn,
      "support_page.html",
      current_sem: current_sem,
      institution: institution,
      users: users,
      changeset: changeset
    )
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

  def lib_access(conn, params) do
    bin = Plug.Crypto.KeyGenerator.generate("resertech", "damien")
    uri = Application.get_env(:school, :api)[:url]

    lib_id = School.Affairs.inst_id(conn)
    # access library
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

    # create user
    user = Repo.get(User, conn.private.plug_session["user_id"])

    name = user.name |> String.split(" ") |> Enum.join("_")
    email = user.email
    encrypted_password = Plug.Crypto.MessageEncryptor.encrypt(user.crypted_password, bin, bin)

    path2 =
      "?scope=create_user&inst_id=sa_#{lib_id}&name=#{name}&email=#{email}&password=#{
        encrypted_password
      }"

    response2 =
      HTTPoison.get!(
        uri <> path2,
        [{"Content-Type", "application/json"}],
        timeout: 50_000,
        recv_timeout: 50_000
      ).body

    data = response2 |> Poison.decode!()

    lib_uri = Application.get_env(:school, :library)[:url]
    lib_path = "admin/authenticate_school/#{email}/#{encrypted_password}"
    lib_uri = lib_uri <> lib_path

    conn
    |> put_flash(:info, "Welcome back to 5chool!")
    |> redirect(external: lib_uri)
  end

  def lib_login(conn, params) do
  end

  def lib_register(conn, params) do
    bin = Plug.Crypto.KeyGenerator.generate("resertech", "damien")

    if params["password"] == params["confirm_password"] do
      encrypted_password = Plug.Crypto.MessageEncryptor.encrypt(params["password"], bin, bin)
      user = Repo.get_by(User, email: params["email"])
      name = user.name |> String.split(" ") |> Enum.join("_")
      uri = Application.get_env(:school, :api)[:url]

      lib_id = School.Affairs.inst_id(conn)

      path =
        "?scope=create_user&inst_id=sa_#{lib_id}&name=#{name}&email=#{params["email"]}&password=#{
          encrypted_password
        }"

      response =
        HTTPoison.get!(
          uri <> path,
          [{"Content-Type", "application/json"}],
          timeout: 50_000,
          recv_timeout: 50_000
        ).body

      data = response |> Poison.decode!()

      if data["message"] == "User created successfully!" do
        user_params = %{is_librarian: true}
        Settings.update_user(user, user_params)
      end

      conn
      |> put_flash(:info, data["message"])
      |> render("lib_login.html")
    else
      conn
      |> put_flash(:error, "Password and Confirmation Password not match!")
      |> render("lib_login.html")
    end
  end

  def books(conn, params) do
    # uri = "https://www.li6rary.net/api"
    uri = Application.get_env(:school, :api)[:url]

    lib_id = School.Affairs.inst_id(conn)

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

    templates =
      if response == "[]" do
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

    template =
      if response == "[]" do
        nil
      else
        response |> Poison.decode!() |> hd()
      end

    lib_id = inst.library_organization_id
    student_ids = params["ids"] |> String.split("\r\n")

    map_list =
      for id <- student_ids do
        student =
          Repo.get_by(
            Student,
            student_no: id,
            institution_id: conn.private.plug_session["institution_id"]
          )

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

  def no_page_found(conn, params) do
    user = Settings.current_user(conn)
    role = user.role

    location =
      case role do
        "Support" ->
          :support_dashboard

        "Admin" ->
          :admin_dashboard

        _ ->
          :dashboard
      end

    conn
    |> put_flash(:error, "No page found!")
    |> redirect(to: page_path(conn, location))
  end
end
