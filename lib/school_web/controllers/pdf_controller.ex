defmodule SchoolWeb.PdfController do
  use SchoolWeb, :controller
  use Task

  require IEx

  def exam_result_standard(conn, params) do
    school = Repo.get(Institution, User.institution_id(conn))

    q =
      from(
        e in ExamMark,
        left_join: s in Student,
        on: s.id == e.student_id,
        left_join: ss in Subject,
        on: ss.id == e.subject_id,
        left_join: c in Class,
        on: c.id == e.class_id,
        left_join: ex in Exam,
        on: ex.id == e.exam_id,
        left_join: em in ExamMaster,
        on: ex.exam_master_id == em.id,
        group_by: [s.chinese_name, s.sex, s.name, c.name, em.year, em.name, em.id],
        select: %{
          gender: s.sex,
          student: s.name,
          c_student: s.chinese_name,
          class: c.name,
          year: em.year,
          exam: em.name,
          exam_mid: em.id
        },
        order_by: [s.name]
      )

    data = Repo.all(q)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "exam_result_standard.html",
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

    # render(conn, "exam_result_standard.html", school: school, data: data)
  end

  def standard_listing(conn, params) do
    school = Repo.get(Institution, User.institution_id(conn))

    semester_start = params["semester"] |> String.split(" - ") |> hd()
    semester_end = params["semester"] |> String.split(" - ") |> tl() |> hd()

    semester =
      Repo.get_by(
        Semester,
        start_date: Date.from_iso8601!(semester_start),
        end_date: Date.from_iso8601!(semester_end)
      )

    q =
      from(
        ss in StandardSubject,
        left_join: l in Level,
        on: l.id == ss.standard_id,
        left_join: s in Subject,
        on: s.id == ss.subject_id,
        select: %{
          year: ss.year,
          subject: s.description,
          code: s.code,
          standard: l.name
        }
      )

    data = Repo.all(q)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "standard_listing.html",
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

    # render(conn, "standard_listing.html", school: school, data: data)
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
