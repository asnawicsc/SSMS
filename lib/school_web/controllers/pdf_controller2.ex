defmodule SchoolWeb.Pdf2Controller do
  use SchoolWeb, :controller
  use Task

  require IEx

  def report_card_all(conn, params) do
    class_name = params["class"]
    semester_id = params["semester"]

    semester = Repo.get_by(School.Affairs.Semester, id: semester_id)

    class_info =
      Repo.get_by(
        School.Affairs.Class,
        name: class_name,
        institution_id: conn.private.plug_session["institution_id"]
      )

    level =
      Repo.get_by(
        School.Affairs.Level,
        id: class_info.level_id,
        institution_id: conn.private.plug_session["institution_id"]
      )

    class_teacher =
      Repo.get_by(
        School.Affairs.Teacher,
        id: class_info.teacher_id,
        institution_id: conn.private.plug_session["institution_id"]
      )

    list_exam =
      Repo.all(from(s in School.Affairs.ExamMaster, where: s.level_id == ^class_info.level_id))

    data =
      Repo.all(
        from(
          s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem),
          order_by: [asc: s.name]
        )
      )

    institute =
      Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

    if data == [] do
      conn
      |> put_flash(:info, "No Data for this Selection")
      |> redirect(to: "/list_report")
    else
      data = data |> Enum.group_by(fn x -> x.stuid end)

      id = institute.id

      school =
        case id do
          10 ->
            "report_cards_sl.html"

          9 ->
            "report_cards_kk.html"

          3 ->
            "report_cards_sk.html"

          _ ->
            "report_cards_sk.html"
        end

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          school,
          a: data,
          level: level,
          list_exam: list_exam,
          institute: institute,
          class_teacher: class_teacher
        )

      pdf_params = %{"html" => html}

      pdf_binary =
        if id == 2 do
          PdfGenerator.generate_binary!(
            pdf_params["html"],
            size: "B5",
            shell_params: [
              "--orientation",
              "Landscape",
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
        else
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
        end

      # put filename... 
      conn
      |> put_resp_header("Content-Type", "application/pdf")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"#{institute.name}_ReportCard_#{class_name}_sem_#{semester.sem}.pdf\""
      )
      |> resp(200, pdf_binary)

      # render(
      #   conn,
      #   "report_cards_sk.html",
      #   a: data,
      #   level: level,
      #   list_exam: list_exam,
      #   institute: institute,
      #   class_teacher: class_teacher,
      #   layout: {SchoolWeb.LayoutView, "blank.html"}
      # )
    end
  end
end
