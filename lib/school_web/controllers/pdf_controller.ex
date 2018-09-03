defmodule SchoolWeb.PdfController do
  use SchoolWeb, :controller
  use Task

  require IEx

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
