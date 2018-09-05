defmodule SchoolWeb.PdfController do
  use SchoolWeb, :controller
  use Task

  require IEx

  def height_weight_report_show(conn, params) do
    school = Repo.get(Institution, User.institution_id(conn))
    semester = Repo.get(Semester, params["semester_id"])

    if params["class_id"] != "all_class" do
      class = Repo.get(Class, params["class_id"])

      students =
        Repo.all(
          from(
            s in Student,
            left_join: c in StudentClass,
            on: c.sudent_id == s.id,
            where: c.class_id == ^params["class_id"] and c.semester_id == ^semester.id,
            order_by: [asc: s.name],
            select: %{
              id: s.id,
              sex: s.sex,
              name: s.name,
              chinese_name: s.chinese_name,
              height: s.height,
              weight: s.weight
            }
          )
        )
    else
      students =
        Repo.all(
          from(
            s in Student,
            left_join: c in StudentClass,
            on: c.sudent_id == s.id,
            left_join: cl in Class,
            on: cl.id == c.class_id,
            where: c.semester_id == ^semester.id,
            order_by: [asc: cl.name],
            select: %{
              class: cl.name,
              id: s.id,
              sex: s.sex,
              name: s.name,
              chinese_name: s.chinese_name,
              height: s.height,
              weight: s.weight
            }
          )
        )
    end

    filter_student =
      for student <- students do
        if params["class_id"] != "all_class" do
          student = Map.put(student, :class, class.name)
        else
          student_class = Repo.get_by(StudentClass, sudent_id: student.id)
          class = Repo.get(Class, student_class.class_id)
        end

        if student.height != nil do
          heights = String.split(student.height, ",")

          height =
            for height <- heights do
              l_id =
                String.split(height, "-") |> List.to_tuple() |> elem(0) |> String.to_integer()

              if l_id == class.level_id do
                height
              end
            end
            |> Enum.reject(fn x -> x == nil end)
            |> List.to_string()
            |> String.split("-")
            |> List.to_tuple()
            |> elem(1)
        end

        if student.weight != nil do
          weights = String.split(student.weight, ",")

          weight =
            for weight <- weights do
              l_id =
                String.split(weight, "-") |> List.to_tuple() |> elem(0) |> String.to_integer()

              if l_id == class.level_id do
                weight
              end
            end
            |> Enum.reject(fn x -> x == nil end)
            |> List.to_string()
            |> String.split("-")
            |> List.to_tuple()
            |> elem(1)
        end

        student = Map.put(student, :height, height)
        student = Map.put(student, :weight, weight)
        student
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "height_weight_report.html",
        students: filter_student,
        school: school
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def class_listing_teacher(conn, params) do
    school = Repo.get(Institution, User.institution_id(conn))
    class_name = params["class"]
    semester_start = params["semester"] |> String.split(" - ") |> hd()
    semester_end = params["semester"] |> String.split(" - ") |> tl() |> hd()

    semester =
      Repo.get_by(
        Semester,
        start_date: Date.from_iso8601!(semester_start),
        end_date: Date.from_iso8601!(semester_end)
      )

    data =
      Repo.all(
        from(
          s in SubjectTeachClass,
          left_join: c in Class,
          on: c.id == s.class_id,
          left_join: l in Level,
          on: l.id == s.standard_id,
          left_join: t in Teacher,
          on: t.id == s.teacher_id,
          left_join: j in Subject,
          on: j.id == s.subject_id,
          select: %{
            class: c.name,
            standard: l.name,
            code: j.code,
            subject: j.description,
            teacher: t.name
          }
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "class_listing_teacher.html",
        school: school,
        data: data
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)

    # render(conn, "class_listing_teacher.html", school: school, data: data)
  end

  def class_analysis(conn, params) do
    school = Repo.get(Institution, User.institution_id(conn))
    class_name = params["class"]
    semester_start = params["semester"] |> String.split(" - ") |> hd()
    semester_end = params["semester"] |> String.split(" - ") |> tl() |> hd()

    semester =
      Repo.get_by(
        Semester,
        start_date: Date.from_iso8601!(semester_start),
        end_date: Date.from_iso8601!(semester_end)
      )

    data =
      Repo.all(
        from(
          s in Student,
          left_join: sc in StudentClass,
          on: sc.sudent_id == s.id,
          left_join: c in Class,
          on: c.id == sc.class_id,
          left_join: l in Level,
          on: l.id == c.level_id,
          left_join: sm in Semester,
          on: sm.id == sc.semester_id,
          where: sc.institute_id == ^User.institution_id(conn),
          group_by: [l.name, c.name, s.sex],
          select: %{
            class: c.name,
            gender: s.sex,
            gender_count: count(s.sex),
            level: l.name
          }
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "class_analysis.html",
        school: school,
        data: data
      )

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)

    # render(conn, "class_analysis.html", school: school, data: data)
  end
end
