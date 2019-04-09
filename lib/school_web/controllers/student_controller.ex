defmodule SchoolWeb.StudentController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Student
  require IEx
  import Mogrify

  require Elixlsx

  alias Elixlsx.Sheet
  alias Elixlsx.Workbook

  def index(conn, _params) do
    students =
      Repo.all(
        from(
          s in Student,
          left_join: g in StudentClass,
          on: s.id == g.sudent_id,
          left_join: k in Class,
          on: k.id == g.class_id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              g.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            image_bin: s.image_bin,
            id: s.id,
            chinese_name: s.chinese_name,
            b_cert: s.b_cert,
            student_no: s.student_no,
            name: s.name,
            class_name: k.name
          },
          order_by: [asc: s.name]
        )
      )

    render(conn, "index.html", students: students)
  end

  def students_transfer(conn, params) do
    curr_semester = Repo.get(Semester, conn.private.plug_session["semester_id"])

    all_semesters =
      Repo.all(
        from(
          s in Semester,
          where:
            s.start_date > ^curr_semester.end_date and
              s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    render(
      conn,
      "student_transfer.html",
      curr_semester: curr_semester,
      all_semesters: all_semesters
    )
  end

  def csv_student_class(conn, params) do
    class =
      if params["class_id"] == "ALL" do
        %{name: "ALL"}
      else
        Repo.get(Class, params["class_id"])
      end

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Student List- #{class.name}.csv\""
    )
    |> send_resp(200, csv_content_stud(conn, params))
  end

  defp csv_content_stud(conn, params) do
    class_id = params["class_id"]
    semester_id = params["semester_id"]

    {male, female} =
      if class_id != "ALL" do
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                id: s.sudent_id,
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                id: s.sudent_id,
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      else
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                id: s.sudent_id,
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                id: s.sudent_id,
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      end

    all = male ++ female

    csv_content = ['No ', 'Name', 'Other Name', 'Sex']

    data =
      for item <- all |> Enum.with_index() do
        no = item |> elem(1)

        item = item |> elem(0)

        [no + 1, item.name, item.chinese_name, item.sex]
      end

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def sheet_cell_insert(sheet, item) do
    sheet = sheet |> Sheet.set_cell(item |> elem(0), item |> elem(1))

    sheet
  end

  def excel_student_class(conn, params) do
    class_id = params["class_id"]
    semester_id = params["semester_id"]

    class =
      if params["class_id"] == "ALL" do
        %{name: "ALL"}
      else
        Repo.get(Class, params["class_id"])
      end

    {male, female} =
      if class_id != "ALL" do
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                no: "0",
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                no: "0",
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      else
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                no: "0",
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                no: "0",
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      end

    all = male ++ female

    all =
      for item <- all |> Enum.with_index() do
        no = item |> elem(1)
        item = item |> elem(0)

        [
          {:no, (no + 1) |> Integer.to_string()},
          {:name, item.name},
          {:chinese_name, item.chinese_name},
          {:sex, item.sex}
        ]
      end

    csv_content = ["No", "Name", "Other Name", "Sex"]

    header =
      for item <- csv_content |> Enum.with_index() do
        no = item |> elem(1)
        start_no = (no + 1) |> Integer.to_string()

        letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)

        alphabert = letters |> Enum.fetch!(no)

        start = alphabert <> "1"

        item = item |> elem(0)

        {start, item}
      end

    data =
      for item <- all |> Enum.with_index() do
        no = item |> elem(1)
        start_no = (no + 2) |> Integer.to_string()
        item = item |> elem(0)

        a =
          for each <- item |> Enum.with_index() do
            letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)
            no = each |> elem(1)

            item = each |> elem(0) |> elem(1)

            alphabert = letters |> Enum.fetch!(no)

            start = alphabert <> start_no

            {start, item}
          end

        a
      end
      |> List.flatten()

    final = header ++ data

    sheet = Sheet.with_name("StudentList")

    total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

    total = total |> Sheet.set_col_width("B", 35.0) |> Sheet.set_col_width("C", 20.0)

    page = %Workbook{sheets: [total]}

    image_path = Application.app_dir(:school, "priv/static/images")

    content = page |> Elixlsx.write_to(image_path <> "/StudentList.xlsx")

    file = File.read!(image_path <> "/StudentList.xlsx")

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"StudentList-#{class.name}.xlsx\""
    )
    |> send_resp(200, file)
  end

  def excel_jpm_class(conn, params) do
    class_id = params["class_id"]
    semester_id = params["semester_id"]

    {male, female} =
      if class_id != "ALL" do
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      else
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                id_no: r.student_no,
                chinese_name: r.chinese_name,
                name: r.name,
                sex: r.sex,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                b_cert: r.b_cert,
                register_date: r.register_date
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      end

    all = male ++ female

    if conn.private.plug_session["institution_id"] == 9 do
      new_all =
        for item <- all do
          dob =
            if item.dob != nil do
              item.dob
            else
            end

          umo_1jan =
            if item.dob != nil do
              a = day = item.dob |> String.split("/") |> Enum.fetch!(2) |> String.to_integer()

              month =
                item.dob
                |> String.split("/")
                |> Enum.fetch!(1)
                |> String.to_integer()

              year = item.dob |> String.split("/") |> Enum.fetch!(0) |> String.to_integer()

              umo_1jan =
                if item.register_date != nil do
                  day_r =
                    item.register_date |> String.split_at(2) |> elem(0) |> String.to_integer()

                  month_r =
                    item.register_date
                    |> String.split_at(5)
                    |> elem(0)
                    |> String.split_at(3)
                    |> elem(1)
                    |> String.to_integer()

                  year_r =
                    item.register_date |> String.split_at(6) |> elem(1) |> String.to_integer()

                  year_total = year_r - 1 - year

                  month_total = 12 - month

                  month_new = month_total |> Integer.to_string()
                  year_new = year_total |> Integer.to_string()

                  umo_1jan = year_new <> "-" <> month_new

                  umo_1jan
                else
                end

              umo_1jan
            else
            end

          %{
            id_no: item.id_no,
            chinese_name: item.chinese_name,
            name: item.name,
            sex: item.sex,
            dob: dob,
            pob: item.pob,
            race: item.race,
            b_cert: item.b_cert,
            register_date: item.register_date,
            umo_1jan: umo_1jan
          }
        end

      number = 40

      add = number - (new_all |> Enum.count())

      range = 1..add

      empty_colum =
        for item <- range do
          %{
            id_no: "",
            chinese_name: "",
            name: "",
            sex: "",
            dob: "",
            pob: "",
            race: "",
            b_cert: "",
            register_date: "",
            umo_1jan: ""
          }
        end

      all = new_all ++ empty_colum

      institution =
        Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

      semester =
        Repo.get_by(School.Affairs.Semester,
          id: semester_id,
          institution_id: conn.private.plug_session["institution_id"]
        )

      class =
        if class_id != "ALL" do
          Repo.get_by(School.Affairs.Class, %{
            id: class_id,
            institution_id: conn.private.plug_session["institution_id"]
          })
        else
          %{name: "ALL"}
        end

      all =
        for item <- all |> Enum.with_index() do
          no = item |> elem(1)
          item = item |> elem(0)

          [
            {:no, (no + 1) |> Integer.to_string()},
            {:id_no, item.id_no},
            {:chinese_name, item.chinese_name},
            {:name, item.name},
            {:sex, item.sex},
            {:dob, item.dob},
            {:pob, item.pob},
            {:umo_1jan, item.umo_1jan},
            {:b_cert, item.b_cert},
            {:register_date, item.register_date},
            {:race, item.race}
          ]
        end

      csv_content = [
        "Bil.",
        "Bil DlmSekolah学学生编号编号",
        "B. (Cina)中文名字",
        "Bahasa Malaysia⻢来⻢来文名字",
        "Jantina性别别",
        "TarikhLahir出生日期",
        "TempatLahir出生地方",
        "UmurPada1hb Jan年龄",
        "No.SijilBeranak出生纸号码纸号码",
        "TarikhMasuk入学学日期",
        "Bangsa种种族"
      ]

      header =
        for item <- csv_content |> Enum.with_index() do
          no = item |> elem(1)
          start_no = (no + 1) |> Integer.to_string()

          letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)

          alphabert = letters |> Enum.fetch!(no)

          start = alphabert <> "1"

          item = item |> elem(0)

          {start, item}
        end

      data =
        for item <- all |> Enum.with_index() do
          no = item |> elem(1)
          start_no = (no + 2) |> Integer.to_string()
          item = item |> elem(0)

          a =
            for each <- item |> Enum.with_index() do
              letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)
              no = each |> elem(1)

              item = each |> elem(0) |> elem(1)

              alphabert = letters |> Enum.fetch!(no)

              start = alphabert <> start_no

              {start, item}
            end

          a
        end
        |> List.flatten()

      final = header ++ data

      sheet = Sheet.with_name("StudentList(JPN)")

      total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

      total = total |> Sheet.set_col_width("B", 35.0) |> Sheet.set_col_width("C", 20.0)

      page = %Workbook{sheets: [total]}

      image_path = Application.app_dir(:school, "priv/static/images")

      content = page |> Elixlsx.write_to(image_path <> "/StudentListJPN.xlsx")

      file = File.read!(image_path <> "/StudentList.xlsx")

      conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"StudentList-#{class.name}.xlsx\""
      )
      |> send_resp(200, file)
    else
      new_all =
        for item <- all do
          dob =
            if item.dob != nil do
              item.dob |> String.split_at(10) |> elem(0) |> String.replace(".", "/")
            else
            end

          umo_1jan =
            if item.dob != nil do
              a = item.dob |> String.split_at(10) |> elem(0)

              day = a |> String.split_at(2) |> elem(0) |> String.to_integer()

              month =
                a
                |> String.split_at(5)
                |> elem(0)
                |> String.split_at(3)
                |> elem(1)
                |> String.to_integer()

              year = a |> String.split_at(6) |> elem(1) |> String.to_integer()

              umo_1jan =
                if item.register_date != nil do
                  day_r =
                    item.register_date |> String.split_at(2) |> elem(0) |> String.to_integer()

                  month_r =
                    item.register_date
                    |> String.split_at(5)
                    |> elem(0)
                    |> String.split_at(3)
                    |> elem(1)
                    |> String.to_integer()

                  year_r =
                    item.register_date |> String.split_at(6) |> elem(1) |> String.to_integer()

                  year_total = year_r - 1 - year

                  month_total = 12 - month

                  month_new = month_total |> Integer.to_string()
                  year_new = year_total |> Integer.to_string()

                  umo_1jan = year_new <> "-" <> month_new

                  umo_1jan
                else
                end

              umo_1jan
            else
            end

          %{
            id_no: item.id_no,
            chinese_name: item.chinese_name,
            name: item.name,
            sex: item.sex,
            dob: dob,
            pob: item.pob,
            race: item.race,
            b_cert: item.b_cert,
            register_date: item.register_date,
            umo_1jan: umo_1jan
          }
        end

      number = 40

      add = number - (new_all |> Enum.count())

      range = 1..add

      empty_colum =
        for item <- range do
          %{
            id_no: "",
            chinese_name: "",
            name: "",
            sex: "",
            dob: "",
            pob: "",
            race: "",
            b_cert: "",
            register_date: "",
            umo_1jan: ""
          }
        end

      all = new_all ++ empty_colum

      institution =
        Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

      semester =
        Repo.get_by(School.Affairs.Semester,
          id: semester_id,
          institution_id: conn.private.plug_session["institution_id"]
        )

      class =
        if class_id != "ALL" do
          Repo.get_by(School.Affairs.Class, %{
            id: class_id,
            institution_id: conn.private.plug_session["institution_id"]
          })
        else
          %{name: "ALL"}
        end

      all =
        for item <- all |> Enum.with_index() do
          no = item |> elem(1)
          item = item |> elem(0)

          [
            {:no, (no + 1) |> Integer.to_string()},
            {:id_no, item.id_no},
            {:chinese_name, item.chinese_name},
            {:name, item.name},
            {:sex, item.sex},
            {:dob, item.dob},
            {:pob, item.pob},
            {:umo_1jan, item.umo_1jan},
            {:b_cert, item.b_cert},
            {:register_date, item.register_date},
            {:race, item.race}
          ]
        end

      csv_content = [
        "Bil.",
        "Bil DlmSekolah学学生编号编号",
        "B. (Cina)中文名字",
        "Bahasa Malaysia⻢来⻢来文名字",
        "Jantina性别别",
        "TarikhLahir出生日期",
        "TempatLahir出生地方",
        "UmurPada1hb Jan年龄",
        "No.SijilBeranak出生纸号码纸号码",
        "TarikhMasuk入学学日期",
        "Bangsa种种族"
      ]

      header =
        for item <- csv_content |> Enum.with_index() do
          no = item |> elem(1)
          start_no = (no + 1) |> Integer.to_string()

          letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)

          alphabert = letters |> Enum.fetch!(no)

          start = alphabert <> "1"

          item = item |> elem(0)

          {start, item}
        end

      data =
        for item <- all |> Enum.with_index() do
          no = item |> elem(1)
          start_no = (no + 2) |> Integer.to_string()
          item = item |> elem(0)

          a =
            for each <- item |> Enum.with_index() do
              letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)
              no = each |> elem(1)

              item = each |> elem(0) |> elem(1)

              alphabert = letters |> Enum.fetch!(no)

              start = alphabert <> start_no

              {start, item}
            end

          a
        end
        |> List.flatten()

      final = header ++ data

      sheet = Sheet.with_name("StudentList(JPN)")

      total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

      total = total |> Sheet.set_col_width("B", 35.0) |> Sheet.set_col_width("C", 20.0)

      page = %Workbook{sheets: [total]}

      image_path = Application.app_dir(:school, "priv/static/images")

      content = page |> Elixlsx.write_to(image_path <> "/StudentListJPN.xlsx")

      file = File.read!(image_path <> "/StudentListJPN.xlsx")

      conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"StudentListJPN-#{class.name}.xlsx\""
      )
      |> send_resp(200, file)
    end
  end

  def excel_student_parent(conn, params) do
    class_id = params["class_id"]
    semester_id = params["semester_id"]

    {male, female} =
      if class_id != "ALL" do
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                chinese_name: r.chinese_name,
                name: r.name,
                icno: r.ic,
                b_cert: r.b_cert,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                country: r.country,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                chinese_name: r.chinese_name,
                name: r.name,
                icno: r.ic,
                b_cert: r.b_cert,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                country: r.country,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      else
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                chinese_name: r.chinese_name,
                name: r.name,
                icno: r.ic,
                b_cert: r.b_cert,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                country: r.country,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                chinese_name: r.chinese_name,
                name: r.name,
                icno: r.ic,
                b_cert: r.b_cert,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                country: r.country,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      end

    all = male ++ female

    all =
      for item <- all do
        ficno = item.ficno
        micno = item.micno

        ficno =
          if ficno == nil do
            ""
          else
            ficno
          end

        micno =
          if micno == nil do
            ""
          else
            micno
          end

        father = Repo.get_by(School.Affairs.Parent, icno: ficno)
        mother = Repo.get_by(School.Affairs.Parent, icno: micno)

        {fhphone, fname} =
          if father != nil do
            fhphone = father.hphone
            fname = father.name

            {fhphone, fname}
          else
            fhphone = ""
            fname = ""

            {fhphone, fname}
          end

        {mphone, mname} =
          if mother != nil do
            mphone = mother.hphone
            mname = mother.name

            {mphone, mname}
          else
            mphone = ""
            mname = ""

            {mphone, mname}
          end

        a =
          if item.line1 != nil do
            item.line1 <> ","
          else
            ","
          end

        b =
          if item.line2 != nil do
            item.line2 <> ","
          else
            ","
          end

        c =
          if item.postcode != nil do
            item.postcode <> ","
          else
            ","
          end

        d =
          if item.town != nil do
            item.town <> ","
          else
            ","
          end

        e =
          if item.state != nil do
            item.state <> ","
          else
            ","
          end

        f =
          if item.country != nil do
            item.country
          else
            ""
          end

        address = a <> b <> c <> d <> e <> f

        %{
          name: item.name,
          chinese_name: item.chinese_name,
          icno: item.icno,
          b_cert: item.b_cert,
          fname: fname,
          fhphone: fhphone,
          mname: mname,
          mphone: mphone,
          address: address
        }
      end

    number = 40

    add = number - (all |> Enum.count())

    range = 1..add

    empty_colum =
      for item <- range do
        %{
          name: "",
          chinese_name: "",
          icno: "",
          b_cert: "",
          fname: "",
          fhphone: "",
          mname: "",
          mphone: "",
          address: ""
        }
      end

    all = all ++ empty_colum

    institution =
      Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

    semester =
      Repo.get_by(School.Affairs.Semester,
        id: semester_id,
        institution_id: conn.private.plug_session["institution_id"]
      )

    class =
      if class_id != "ALL" do
        Repo.get_by(School.Affairs.Class, %{
          id: class_id,
          institution_id: conn.private.plug_session["institution_id"]
        })
      else
        %{name: "ALL"}
      end

    all =
      for item <- all |> Enum.with_index() do
        no = item |> elem(1)
        item = item |> elem(0)

        [
          {:no, (no + 1) |> Integer.to_string()},
          {:name, item.name},
          {:chinese_name, item.chinese_name},
          {:icno, item.icno},
          {:b_cert, item.b_cert},
          {:fname, item.fname},
          {:fhphone, item.fhphone},
          {:mname, item.mname},
          {:mphone, item.mphone},
          {:address, item.address}
        ]
      end

    csv_content = [
      "No.",
      "Name",
      "中文姓名",
      "No.KP",
      "No. Sijil Lahir",
      "Nama Bapa",
      "No. Tel Bimbit Bapa",
      "Nama Ibu",
      "No. Tel Bimbit Ibu",
      "Alamat Rumah"
    ]

    header =
      for item <- csv_content |> Enum.with_index() do
        no = item |> elem(1)
        start_no = (no + 1) |> Integer.to_string()

        letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)

        alphabert = letters |> Enum.fetch!(no)

        start = alphabert <> "1"

        item = item |> elem(0)

        {start, item}
      end

    data =
      for item <- all |> Enum.with_index() do
        no = item |> elem(1)
        start_no = (no + 2) |> Integer.to_string()
        item = item |> elem(0)

        a =
          for each <- item |> Enum.with_index() do
            letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)
            no = each |> elem(1)

            item = each |> elem(0) |> elem(1)

            alphabert = letters |> Enum.fetch!(no)

            start = alphabert <> start_no

            {start, item}
          end

        a
      end
      |> List.flatten()

    final = header ++ data

    sheet = Sheet.with_name("StudentList(ParentInfo)")

    total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

    total =
      total
      |> Sheet.set_col_width("B", 35.0)
      |> Sheet.set_col_width("C", 20.0)
      |> Sheet.set_col_width("D", 20.0)
      |> Sheet.set_col_width("E", 20.0)
      |> Sheet.set_col_width("G", 20.0)
      |> Sheet.set_col_width("J", 50.0)
      |> Sheet.set_col_width("F", 35.0)
      |> Sheet.set_col_width("H", 35.0)

    page = %Workbook{sheets: [total]}

    image_path = Application.app_dir(:school, "priv/static/images")

    content = page |> Elixlsx.write_to(image_path <> "/StudentList-ParentInfo.xlsx")

    file = File.read!(image_path <> "/StudentList-ParentInfo.xlsx")

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"StudentList-ParentInfo-#{class.name}.xlsx\""
    )
    |> send_resp(200, file)
  end

  def excel_selection_student_class(conn, params) do
    class_id = params["class_id"]
    semester_id = params["semester_id"]

    render(conn, "selection_page.html", class_id: class_id, semester_id: semester_id)
  end

  def generate_student_list_selection(conn, params) do
    class_id = params["class_id"]
    semester_id = params["semester_id"]

    if params["selection"] != nil do
      params["selection"]
    else
      url = student_path(conn, :excel_selection_student_class)

      conn
      |> put_flash(:info, "Please Select Field Selection")
      |> redirect(external: url)
    end

    class =
      if params["class_id"] == "ALL" do
        %{name: "ALL"}
      else
        Repo.get(Class, params["class_id"])
      end

    {male, female} =
      if class_id != "ALL" do
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                student_no: r.student_no,
                b_cert: r.b_cert,
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex,
                ic: r.ic,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                religion: r.religion,
                nationality: r.nationality,
                country: r.country,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                phone: r.phone,
                blood_type: r.blood_type,
                gicno: r.gicno,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                s.class_id == ^class_id and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                student_no: r.student_no,
                b_cert: r.b_cert,
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex,
                ic: r.ic,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                religion: r.religion,
                nationality: r.nationality,
                country: r.country,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                phone: r.phone,
                blood_type: r.blood_type,
                gicno: r.gicno,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      else
        male =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "M",
              select: %{
                student_no: r.student_no,
                b_cert: r.b_cert,
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex,
                ic: r.ic,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                religion: r.religion,
                nationality: r.nationality,
                country: r.country,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                phone: r.phone,
                blood_type: r.blood_type,
                gicno: r.gicno,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        female =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: g in School.Affairs.Class,
              on: s.class_id == g.id,
              left_join: r in School.Affairs.Student,
              on: r.id == s.sudent_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  r.institution_id == ^conn.private.plug_session["institution_id"] and
                  s.semester_id == ^semester_id and r.sex == "F",
              select: %{
                student_no: r.student_no,
                b_cert: r.b_cert,
                name: r.name,
                chinese_name: r.chinese_name,
                sex: r.sex,
                ic: r.ic,
                dob: r.dob,
                pob: r.pob,
                race: r.race,
                religion: r.religion,
                nationality: r.nationality,
                country: r.country,
                line1: r.line1,
                line2: r.line2,
                postcode: r.postcode,
                town: r.town,
                state: r.state,
                phone: r.phone,
                blood_type: r.blood_type,
                gicno: r.gicno,
                ficno: r.ficno,
                micno: r.micno
              },
              order_by: [asc: r.name]
            )
          )

        {male, female}
      end

    all = male ++ female

    all =
      for item <- all |> Enum.with_index() do
        no = item |> elem(1)
        item = item |> elem(0)

        true_sort = true_sort(params["selection"])

        all =
          for select <- true_sort do
            sele = select |> String.to_atom()

            fe = item |> Map.fetch!(sele)

            {sele, fe}
          end

        all
      end

    true_sort = true_sort(params["selection"])

    header =
      for item <- true_sort |> Enum.with_index() do
        no = item |> elem(1)
        start_no = (no + 1) |> Integer.to_string()

        letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)

        alphabert = letters |> Enum.fetch!(no)

        start = alphabert <> "1"

        item = item |> elem(0) |> String.upcase()

        {start, item}
      end

    data =
      for item <- all |> Enum.with_index() do
        no = item |> elem(1)
        start_no = (no + 2) |> Integer.to_string()
        item = item |> elem(0)

        a =
          for each <- item |> Enum.with_index() do
            letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)
            no = each |> elem(1)

            item = each |> elem(0) |> elem(1)

            alphabert = letters |> Enum.fetch!(no)

            start = alphabert <> start_no

            {start, item}
          end

        a
      end
      |> List.flatten()

    final = header ++ data

    sheet = Sheet.with_name("StudentListSelection")

    total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

    total =
      total
      |> Sheet.set_col_width("B", 35.0)
      |> Sheet.set_col_width("C", 35.0)
      |> Sheet.set_col_width("D", 35.0)
      |> Sheet.set_col_width("E", 35.0)
      |> Sheet.set_col_width("F", 35.0)
      |> Sheet.set_col_width("G", 35.0)
      |> Sheet.set_col_width("H", 35.0)
      |> Sheet.set_col_width("I", 35.0)
      |> Sheet.set_col_width("J", 35.0)
      |> Sheet.set_col_width("K", 35.0)
      |> Sheet.set_col_width("L", 35.0)
      |> Sheet.set_col_width("M", 35.0)
      |> Sheet.set_col_width("N", 35.0)
      |> Sheet.set_col_width("O", 35.0)

    page = %Workbook{sheets: [total]}

    image_path = Application.app_dir(:school, "priv/static/images")

    content = page |> Elixlsx.write_to(image_path <> "/StudentListSelection.xlsx")

    file = File.read!(image_path <> "/StudentListSelection.xlsx")

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"StudentListSelection-#{class.name}.xlsx\""
    )
    |> send_resp(200, file)
  end

  defp true_sort(selection) do
    selection = selection |> Enum.map(fn x -> x end) |> Enum.map(fn x -> x |> elem(0) end)

    attrs =
      [
        :student_no,
        :name,
        :chinese_name,
        :sex,
        :b_cert,
        :ic,
        :phone,
        :dob,
        :pob,
        :race,
        :line1,
        :line2,
        :postcode,
        :town,
        :state,
        :nationality,
        :religion,
        :country,
        :blood_type,
        :gicno,
        :ficno,
        :micno
      ]
      |> Enum.map(fn x -> Atom.to_string(x) end)

    true_sort =
      for item <- attrs do
        for items <- selection do
          selection |> Enum.filter(fn x -> x == item end)
        end
      end
      |> List.flatten()
      |> Enum.uniq()
  end

  def submit_student_transfer(conn, params) do
    students =
      Repo.all(
        from(
          sc in StudentClass,
          left_join: s in Student,
          on: sc.sudent_id == s.id,
          left_join: c in Class,
          on: sc.class_id == c.id,
          where:
            sc.institute_id == ^conn.private.plug_session["institution_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              sc.semester_id == ^conn.private.plug_session["semester_id"] and
              c.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            student_id: sc.sudent_id,
            semester_id: sc.semester_id,
            class_id: sc.class_id
          }
        )
      )

    for student <- students do
      if student.class_id != nil do
        cur_class =
          Repo.get_by(Class,
            id: student.class_id,
            institution_id: conn.private.plug_session["institution_id"]
          )

        if cur_class.next_class != nil and cur_class.next_class != "Graduate" do
          next_class =
            Repo.get_by(Class,
              id: cur_class.next_class,
              institution_id: conn.private.plug_session["institution_id"]
            )

          student_param = %{
            class_id: next_class.id,
            institute_id: conn.private.plug_session["institution_id"],
            level_id: next_class.level_id,
            semester_id: params["next_semester_id"],
            sudent_id: student.student_id
          }

          Affairs.create_student_class(student_param)
        end
      end
    end

    conn
    |> put_flash(:info, "All students transferred to next semester successfully !")
    |> redirect(to: student_path(conn, :students_transfer))
  end

  def height_weight_semester(conn, params) do
    user = Repo.get(User, conn.private.plug_session["user_id"])
    semester_id = conn.private.plug_session["semester_id"] |> Integer.to_string()

    students =
      Repo.all(
        from(
          s in Student,
          left_join: c in StudentClass,
          on: c.sudent_id == s.id,
          where:
            c.class_id == ^params["class_id"] and
              c.semester_id == ^conn.private.plug_session["semester_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"],
          order_by: [asc: s.name],
          select: %{
            id: s.id,
            name: s.name,
            chinese_name: s.chinese_name,
            height: s.height,
            weight: s.weight
          }
        )
      )

    students =
      for student <- students do
        height =
          if student.height != nil do
            heights = String.split(student.height, ",")

            height_list =
              for height <- heights do
                l_id = String.split(height, "-") |> List.to_tuple() |> elem(0)

                if l_id == semester_id do
                  height
                end
              end
              |> Enum.reject(fn x -> x == nil end)

            if height_list != [] do
              hd(height_list) |> String.split("-") |> List.to_tuple() |> elem(1)
            else
              nil
            end
          else
            nil
          end

        weight =
          if student.weight != nil do
            weights = String.split(student.weight, ",")

            weight =
              for weight <- weights do
                l_id = String.split(weight, "-") |> List.to_tuple() |> elem(0)

                if l_id == semester_id do
                  weight
                end
              end
              |> Enum.reject(fn x -> x == nil end)

            if weight != [] do
              hd(weight) |> String.split("-") |> List.to_tuple() |> elem(1)
            else
              nil
            end
          else
            nil
          end

        student = Map.put(student, :height, height)
        student = Map.put(student, :weight, weight)
      end

    render(conn, "height_weight_semester.html", students: students, semester_id: semester_id)
  end

  def edit_height_weight_all(conn, params) do
    semester_id = conn.private.plug_session["semester_id"] |> Integer.to_string()

    students =
      Repo.all(
        from(
          st in StudentClass,
          left_join: s in Student,
          on:
            s.id == st.sudent_id and
              s.institution_id == ^conn.private.plug_session["institution_id"],
          where:
            st.class_id == ^params["class_id"] and
              st.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            id: st.sudent_id,
            name: s.name,
            chinese_name: s.chinese_name,
            image_bin: s.image_bin,
            height: s.height,
            weight: s.weight
          },
          order_by: [asc: s.name]
        )
      )

    render(conn, "edit_height_weight_all.html",
      students: students,
      semester_id: semester_id,
      class_id: params["class_id"]
    )
  end

  def edit_height_weight(conn, params) do
    student = Repo.get(Student, params["student_id"])

    height =
      if student.height != nil do
        heights = String.split(student.height, ",")

        height_list =
          for height <- heights do
            l_id = String.split(height, "-") |> List.to_tuple() |> elem(0)

            if l_id == params["semester_id"] do
              height
            end
          end
          |> Enum.reject(fn x -> x == nil end)

        if height_list != [] do
          hd(height_list) |> String.split("-") |> List.to_tuple() |> elem(1)
        else
          nil
        end
      else
        nil
      end

    weight =
      if student.weight != nil do
        weights = String.split(student.weight, ",")

        weight =
          for weight <- weights do
            l_id = String.split(weight, "-") |> List.to_tuple() |> elem(0)

            if l_id == params["semester_id"] do
              weight
            end
          end
          |> Enum.reject(fn x -> x == nil end)

        if weight != [] do
          hd(weight) |> String.split("-") |> List.to_tuple() |> elem(1)
        else
          nil
        end
      else
        nil
      end

    student = Map.put(student, :height, height)
    student = Map.put(student, :weight, weight)

    render(conn, "edit_height_weight.html", student: student, semester_id: params["semester_id"])
  end

  def submit_height_weight_all(conn, params) do
    student = params["student"]
    semester_id = params["semester_id"]
    class_id = params["class_id"]

    for item <- student do
      student_id = item |> elem(0)

      student = Repo.get(Student, student_id)

      heg = item |> elem(1) |> Enum.fetch!(0) |> elem(1)
      weg = item |> elem(1) |> Enum.fetch!(1) |> elem(1)

      height =
        if heg == "0" do
          height = Enum.join([params["semester_id"], heg], "-")
          # weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
        else
          cur_height = Enum.join([params["semester_id"], heg], "-")
          ex_height = String.split(student.height, ",")

          lists =
            for ex <- ex_height do
              l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

              if l_id != semester_id do
                ex
              end
            end
            |> Enum.reject(fn x -> x == nil end)

          if lists != [] do
            lists = Enum.join(lists, ",")
            Enum.join([lists, cur_height], ",")
          else
            Enum.join([params["semester_id"], heg], "-")
          end
        end

      weight =
        if weg == "0" do
          weight = Enum.join([params["semester_id"], weg], "-")
          # weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
        else
          cur_weight = Enum.join([params["semester_id"], weg], "-")
          ex_weight = String.split(student.weight, ",")

          lists =
            for ex <- ex_weight do
              l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

              if l_id != semester_id do
                ex
              end
            end
            |> Enum.reject(fn x -> x == nil end)

          if lists != [] do
            lists = Enum.join(lists, ",")
            Enum.join([lists, cur_weight], ",")
          else
            Enum.join([params["semester_id"], weg], "-")
          end
        end

      Student.changeset(student, %{
        height: height,
        weight: weight
      })
      |> Repo.update()
    end

    conn
    |> put_flash(:info, "Height and weight updated successfully.")
    |> redirect(to: "/class_setting/#{class_id}")
  end

  def submit_height_weight(conn, params) do
    student = Repo.get(Student, params["student_id"])

    height =
      if student.height == nil do
        height = Enum.join([params["semester_id"], params["height"]], "-")
        # weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
      else
        cur_height = Enum.join([params["semester_id"], params["height"]], "-")
        ex_height = String.split(student.height, ",")

        lists =
          for ex <- ex_height do
            l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

            if l_id != params["semester_id"] do
              ex
            end
          end
          |> Enum.reject(fn x -> x == nil end)

        if lists != [] do
          lists = Enum.join(lists, ",")
          Enum.join([lists, cur_height], ",")
        else
          Enum.join([params["semester_id"], params["height"]], "-")
        end
      end

    weight =
      if student.weight == nil do
        weight = Enum.join([params["semester_id"], params["weight"]], "-")
      else
        cur_weight = Enum.join([params["semester_id"], params["weight"]], "-")
        ex_weight = String.split(student.weight, ",")

        lists2 =
          for ex <- ex_weight do
            l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

            if l_id != params["semester_id"] do
              ex
            end
          end
          |> Enum.reject(fn x -> x == nil end)

        if lists2 != [] do
          lists2 = Enum.join(lists2, ",")
          Enum.join([lists2, cur_weight], ",")
        else
          Enum.join([params["semester_id"], params["weight"]], "-")
        end
      end

    Student.changeset(student, %{
      height: height,
      weight: weight
    })
    |> Repo.update()

    conn
    |> put_flash(:info, "Height and weight updated successfully.")
    |> redirect(to: "/edit_height_weight/#{params["student_id"]}/#{params["semester_id"]}")
  end

  def student_lists(conn, params) do
    user = Repo.get(User, params["user_id"])

    {students} =
      if user.role == "Teacher" do
        teacher = Repo.all(from(t in Teacher, where: t.email == ^user.email))

        if teacher != nil do
          teacher = teacher |> hd()
          all_class = Repo.all(from(c in Class, where: c.teacher_id == ^teacher.id))

          students =
            for class <- all_class do
              student_ids =
                Repo.all(
                  from(
                    s in StudentClass,
                    where: s.class_id == ^class.id,
                    select: %{student_id: s.sudent_id}
                  )
                )

              student_ids
            end

          students = students |> List.flatten()

          students =
            for student <- students do
              details =
                Repo.all(
                  from(
                    s in Student,
                    left_join: c in StudentClass,
                    on: c.sudent_id == s.id,
                    left_join: cl in Class,
                    on: cl.id == c.class_id,
                    where:
                      s.id == ^student.student_id and
                        s.institution_id == ^conn.private.plug_session["institution_id"] and
                        c.institute_id == ^conn.private.plug_session["institution_id"] and
                        cl.institution_id == ^conn.private.plug_session["institution_id"] and
                        c.semester_id == ^conn.private.plug_session["semester_id"],
                    order_by: [asc: s.name],
                    select: %{
                      image_bin: s.image_bin,
                      id: s.id,
                      chinese_name: s.chinese_name,
                      b_cert: s.b_cert,
                      student_no: s.student_no,
                      name: s.name,
                      class_name: cl.name
                    }
                  )
                )

              details
            end
            |> List.flatten()

          {students}
        end
      else
        # for non teacher to view all students
        students =
          Repo.all(
            from(
              s in Student,
              left_join: c in StudentClass,
              on: c.sudent_id == s.id,
              left_join: cl in Class,
              on: cl.id == c.class_id,
              where:
                s.institution_id == ^conn.private.plug_session["institution_id"] and
                  c.institute_id == ^conn.private.plug_session["institution_id"] and
                  cl.institution_id == ^conn.private.plug_session["institution_id"] and
                  c.semester_id == ^conn.private.plug_session["semester_id"],
              order_by: [asc: s.name],
              select: %{
                image_bin: s.image_bin,
                id: s.id,
                chinese_name: s.chinese_name,
                b_cert: s.b_cert,
                student_no: s.student_no,
                name: s.name,
                class_name: cl.name
              }
            )
          )

        {students}
      end

    render(conn, "index.html", students: students)
  end

  def student_certificate(conn, params) do
    semesters =
      Repo.all(from(s in Semester))
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "student_certificate.html", semesters: semesters)
  end

  def height_weight(conn, params) do
    students =
      Repo.all(
        from(
          s in Student,
          left_join: c in StudentClass,
          on: c.sudent_id == s.id,
          where:
            c.class_id == ^params["class_id"] and
              c.semester_id == ^conn.private.plug_session["semester_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"],
          order_by: [asc: s.name],
          select: %{
            id: s.id,
            name: s.name,
            chinese_name: s.chinese_name
          }
        )
      )

    semester =
      Repo.all(
        from(
          s in Semester,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{id: s.id, start_date: s.start_date, end_date: s.end_date}
        )
      )

    new_semesters =
      for each <- semester do
        name = Enum.join([each.start_date, each.end_date], " - ")
        each = Map.put(each, :name, name)
        each
      end

    render(conn, "height_weight.html", students: students, levels: new_semesters)
  end

  def height_weight_class(conn, params) do
    students =
      Repo.all(
        from(
          s in Student,
          left_join: c in StudentClass,
          on: c.sudent_id == s.id,
          where:
            c.class_id == ^params["class_id"] and
              c.semester_id == ^conn.private.plug_session["semester_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"],
          order_by: [asc: s.name],
          select: %{
            id: s.id,
            name: s.name,
            chinese_name: s.chinese_name
          }
        )
      )

    # student_class = Repo.all(from(s in StudentClass, where: s.class_id == ^params["class_id"]))
    # level_id = hd(student_class).level_id
    # level = Repo.all(from(l in Level, where: l.id == ^level_id))

    render(conn, "height_weight.html", students: students)
  end

  def new(conn, _params) do
    changeset = Affairs.change_student(%Student{})

    render(conn, "new.html", changeset: changeset)
  end

  def pre_generate_student_class(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.create_batch(%{upload_by: usr.id, result: bin})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)

    render(conn, "adjust_header_generate.html", headers: headers, batch_id: batch.id)
  end

  def upload_generate_student_class(conn, params) do
    batch = Settings.get_batch!(params["batch_id"])
    bin = batch.result
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.update_batch(batch, %{upload_by: usr.id})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers =
      hd(data)
      |> Enum.map(fn x -> String.trim(x, " ") end)
      |> Enum.map(fn x -> params["header"][x] end)

    contents = tl(data) |> Enum.reject(fn x -> x == [""] end) |> Enum.uniq() |> Enum.sort()

    Task.start_link(__MODULE__, :loop, [conn, contents, headers, batch])

    conn
    |> put_flash(:info, "Student Class created successfully.")
    |> redirect(to: student_path(conn, :index))
  end

  def loop(conn, contents, headers, batch) do
    result =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

        content = content |> Enum.map(fn x -> x end) |> Enum.filter(fn x -> x != "\"" end)

        c =
          for item <- content do
            item =
              case item do
                "@@@" ->
                  ","

                "\\N" ->
                  ""

                _ ->
                  item
              end

            a =
              case item do
                {:ok, i} ->
                  i

                _ ->
                  cond do
                    item == " " ->
                      "null"

                    item == "  " ->
                      "null"

                    item == "   " ->
                      "null"

                    true ->
                      item
                      |> String.split("\"")
                      |> Enum.map(fn x -> String.replace(x, "\n", "") end)
                      |> List.last()
                  end
              end
          end

        student_param = Enum.zip(h, c) |> Enum.into(%{})

        institution_id = conn.private.plug_session["institution_id"]

        student_id =
          Repo.get_by(
            Affairs.Student,
            student_no: student_param["student_id"],
            institution_id: conn.private.plug_session["institution_id"]
          )

        if student_id != nil do
          class_id =
            Repo.get_by(
              Affairs.Class,
              name: student_param["class_name"],
              institution_id: conn.private.plug_session["institution_id"]
            )

          if class_id != nil do
            semester_id =
              Repo.get_by(
                Affairs.Semester,
                year: student_param["year"],
                sem: student_param["sem"],
                institution_id: conn.private.plug_session["institution_id"]
              )

            if semester_id != nil do
              param = %{
                class_id: class_id.id,
                institute_id: institution_id,
                semester_id: semester_id.id,
                sudent_id: student_id.id
              }

              cg = StudentClass.changeset(%StudentClass{}, param)

              Repo.insert(cg)
            end
          end
        end
      end
  end

  def pre_upload_students(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.create_batch(%{upload_by: usr.id, result: bin})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)

    render(conn, "adjust_header.html", headers: headers, batch_id: batch.id)
  end

  def upload_students(conn, params) do
    batch = Settings.get_batch!(params["batch_id"])
    bin = batch.result
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.update_batch(batch, %{upload_by: usr.id})

    data =
      if bin |> String.contains?("\t") do
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, "\t") end)
      else
        bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
      end

    headers =
      hd(data)
      |> Enum.map(fn x -> String.trim(x, " ") end)
      |> Enum.map(fn x -> params["header"][x] end)
      |> Enum.reject(fn x -> x == nil end)

    contents = tl(data)

    result =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

        content = content |> Enum.map(fn x -> x end) |> Enum.filter(fn x -> x != "\"" end)

        c =
          for item <- content do
            item =
              case item do
                "@@@" ->
                  ","

                "\\N" ->
                  ""

                _ ->
                  item
              end

            a =
              case item do
                {:ok, i} ->
                  i

                _ ->
                  cond do
                    item == " " ->
                      "null"

                    item == "  " ->
                      "null"

                    item == "   " ->
                      "null"

                    true ->
                      item
                      |> String.split("\"")
                      |> Enum.map(fn x -> String.replace(x, "\n", "") end)
                      |> List.last()
                  end
              end
          end

        student_param = Enum.zip(h, c) |> Enum.into(%{})

        student_param =
          Map.put(student_param, "institution_id", conn.private.plug_session["institution_id"])

        cg = Student.changeset(%Student{}, student_param)

        case Repo.insert(cg) do
          {:ok, student} ->
            student_param
            student_param = Map.put(student_param, "reason", "ok")

          {:error, changeset} ->
            errors = changeset.errors |> Keyword.keys()

            {reason, message} = changeset.errors |> hd()
            {proper_message, message_list} = message
            final_reason = Atom.to_string(reason) <> " " <> proper_message
            student_param = Map.put(student_param, "reason", final_reason)

            student_param
        end
      end

    header = result |> hd() |> Map.keys()
    body = result |> Enum.map(fn x -> Map.values(x) end)
    new_io = List.insert_at(body, 0, header) |> CSV.encode() |> Enum.to_list() |> to_string
    {:ok, batch} = Settings.update_batch(batch, %{result: new_io})

    conn
    |> put_flash(:info, "Student created successfully.")
    |> redirect(to: student_path(conn, :index))
  end

  def create(conn, %{"student" => student_params}) do
    student_params =
      Map.put(student_params, "institution_id", conn.private.plug_session["institution_id"])

    image_params = student_params["image1"]

    student_params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        student_params = Map.put(student_params, "image_bin", result.bin)
        student_params = Map.put(student_params, "image_filename", result.filename)
      else
        student_params
      end

    case Affairs.create_student(student_params) do
      {:ok, student} ->
        conn
        |> put_flash(:info, "Student created successfully.")
        |> redirect(to: student_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def upload_image(param, conn) do
    {:ok, seconds} = Timex.format(Timex.now(), "%s", :strftime)

    institute = Repo.get(Institution, conn.private.plug_session["institution_id"])

    path = File.cwd!() <> "/media/" <> institute.name
    image_path = Application.app_dir(:school, "priv/static/images")

    if File.exists?(path) == false do
      File.mkdir(File.cwd!() <> "/media/" <> institute.name)
    end

    fl = param.filename |> String.replace(" ", "_")
    absolute_path = path <> "/#{seconds <> fl}"
    absolute_path_bin = path <> "/bin_" <> "#{seconds <> fl}"
    File.cp(param.path, absolute_path)
    File.rm(image_path <> "/uploads")
    File.ln_s(path, image_path <> "/uploads")

    resized = Mogrify.open(absolute_path) |> resize("200x200") |> save(path: absolute_path_bin)
    {:ok, bin} = File.read(resized.path)

    # File.rm(resized.path)

    %{filename: seconds <> fl, bin: Base.encode64(bin)}
  end

  def generate_student_image(conn, params) do
    all_params = params["item"]["image1"]

    for image_params <- all_params do
      result = upload_image(image_params, conn)

      params = Map.put(params, "image_bin", result.bin)
      params = Map.put(params, "image_filename", result.filename)

      student = image_params

      student_no = student.filename |> String.split(".") |> hd

      student =
        Repo.get_by(Student,
          student_no: student_no,
          institution_id: conn.private.plug_session["institution_id"]
        )

      if student != nil do
        student_params = %{image_bin: result.bin, image_filename: result.filename}

        Affairs.update_student(student, student_params)
      else
      end
    end

    conn
    |> put_flash(:info, "Student Upload Succesfully")
    |> redirect(to: student_path(conn, :index))
  end

  def print_students(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)

    all_student =
      Repo.all(
        from(
          sc in School.Affairs.StudentClass,
          left_join: s in School.Affairs.Student,
          on: s.id == sc.sudent_id,
          where: sc.class_id == ^class.id,
          select: %{
            name: s.name,
            chinese_name: s.chinese_name,
            sex: s.sex,
            student_no: s.student_no
          }
        )
      )
      |> Enum.with_index()

    render(conn, "print_students.html", all_student: all_student, class_name: class.name)
  end

  def show(conn, %{"id" => id}) do
    student = Affairs.get_student!(id)
    render(conn, "show.html", student: student)
  end

  def edit(conn, %{"id" => id}) do
    student = Affairs.get_student!(id)
    changeset = Affairs.change_student(student)

    render(conn, "edit.html", student: student, changeset: changeset)
  end

  def update(conn, %{"id" => id, "student" => student_params}) do
    student = Affairs.get_student!(id)

    case Affairs.update_student(student, student_params) do
      {:ok, student} ->
        url = student_path(conn, :index, focus: student.id)
        referer = conn.req_headers |> Enum.filter(fn x -> elem(x, 0) == "referer" end)

        if referer != [] do
          refer = hd(referer)
          url = refer |> elem(1) |> String.split("?") |> List.first()

          conn
          |> put_flash(:info, "#{student.name} updated successfully.")
          |> redirect(external: url <> "?focus=#{student.id}")
        else
          conn
          |> put_flash(:info, "#{student.name} updated successfully.")
          |> redirect(to: url)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", student: student, changeset: changeset)
    end
  end

  def update_changes(conn, params) do
    student = Affairs.get_student!(params["student_id"])

    image_params = params["image1"]

    params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        Map.put(params, "image_bin", result.bin)
      else
        params
      end

    params =
      if image_params != nil do
        result = upload_image(image_params, conn)

        Map.put(params, "image_filename", result.filename)
      else
        params
      end

    studentss = Student.changeset(student, params)

    case Repo.update(studentss) do
      {:ok, student} ->
        url = student_path(conn, :index, focus: student.id)
        referer = conn.req_headers |> Enum.filter(fn x -> elem(x, 0) == "referer" end)

        if referer != [] do
          refer = hd(referer)
          url = refer |> elem(1) |> String.split("?") |> List.first()

          conn
          |> put_flash(:info, "#{student.name} updated successfully.")
          |> redirect(external: url <> "?focus=#{student.id}")
        else
          conn
          |> put_flash(:info, "#{student.name} updated successfully.")
          |> redirect(to: url)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = changeset.errors |> Keyword.keys()

        {reason, message} = changeset.errors |> hd()
        {proper_message, message_list} = message
        final_reason = Atom.to_string(reason) <> " " <> proper_message

        conn
        |> put_flash(:info, final_reason)
        |> redirect(to: student_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    student = Affairs.get_student!(id)
    {:ok, _student} = Affairs.delete_student(student)

    conn
    |> put_flash(:info, "Student deleted successfully.")
    |> redirect(to: student_path(conn, :index))
  end
end
