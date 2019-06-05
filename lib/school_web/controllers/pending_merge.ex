defmodule SchoolWeb.Pdf3Controller do
  use SchoolWeb, :controller
  use Task
  import Mogrify

  require Elixlsx

  alias Elixlsx.Sheet
  alias Elixlsx.Workbook

  require IEx

  def student_transfer_pdf(conn, params) do
    semesters =
      Repo.all(
        from(
          s in Semester,
          where: s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    semesters = [%{id: conn.private.plug_session["semester_id"]}, %{id: params["semester_id"]}]

    students =
      for semester <- semesters do
        Repo.all(
          from(
            s in Student,
            left_join: sc in StudentClass,
            on: sc.sudent_id == s.id,
            left_join: c in Class,
            on: c.id == sc.class_id,
            left_join: sm in Semester,
            on: sm.id == sc.semester_id,
            where: sm.id == ^semester.id,
            select: %{
              student_id: s.id,
              name: s.name,
              class_id: sc.class_id
            }
          )
        )
      end
      |> List.flatten()
      |> Enum.sort_by(fn x -> x.class_id end)
      |> Enum.dedup()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "student_transfer_listing.html",
        semesters: semesters,
        students: students
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

  def rerun_all_temp(conn, params) do
    semester = Repo.get_by(School.Affairs.Semester, id: conn.private.plug_session["semester_id"])

    institute =
      Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

    subject =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          where: s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    student_class_data =
      Repo.all(
        from(
          s in School.Affairs.Student,
          left_join: g in School.Affairs.StudentClass,
          on: s.id == g.sudent_id,
          left_join: k in School.Affairs.Class,
          on: k.id == g.class_id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              g.semester_id == ^conn.private.plug_session["semester_id"],
          # and
          # g.class_id == ^class_info.id,
          select: %{
            student_id: s.id,
            student_name: s.name,
            chinese_name: s.chinese_name,
            class_name: k.name,
            class_id: g.class_id
          }
        )
      )

    IO.puts("finish student class data")

    list_exam_data =
      Repo.all(
        from(
          s in School.Affairs.ExamMaster,
          # s.level_id == ^class_info.level_id and
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"]
        )
      )
      |> Enum.sort()

    IO.puts("finish list exam data")

    exam_big_data =
      Repo.all(
        from(
          em in School.Affairs.ExamMark,
          left_join: z in School.Affairs.Exam,
          on: em.exam_id == z.id,
          left_join: e in School.Affairs.ExamMaster,
          on: z.exam_master_id == e.id,
          left_join: j in School.Affairs.Semester,
          on: e.semester_id == j.id,
          left_join: s in School.Affairs.Student,
          on: em.student_id == s.id,
          left_join: sc in School.Affairs.StudentClass,
          on: sc.sudent_id == s.id,
          left_join: c in School.Affairs.Class,
          on: sc.class_id == c.id,
          left_join: sb in School.Affairs.Subject,
          on: em.subject_id == sb.id,
          # c.name == ^class_name and 
          where: sc.semester_id == ^conn.private.plug_session["semester_id"],
          # and em.subject_id == ^item.id 
          # and em.student_id == ^stud_class.student_id,
          select: %{
            student_id: s.id,
            student_name: s.name,
            chinese_name: s.chinese_name,
            class_name: c.name,
            exam_master_id: e.id,
            exam_name: e.name,
            semester: j.id,
            semester_no: j.sem,
            year: j.year,
            subject_code: sb.code,
            subject_name: sb.description,
            subject_cname: sb.cdesc,
            mark: em.mark,
            grade: em.grade,
            standard_id: sc.level_id,
            em_subject_id: em.subject_id,
            em_student_id: em.student_id,
            e_level_id: e.level_id,
            sb_with_mark: sb.with_mark,
            student_heigt: s.height,
            student_weight: s.weight,
            e_level_id: e.level_id
          }
        )
      )

    IO.puts("finish exam big data")

    list_class_data =
      Repo.all(
        from(
          s in School.Affairs.Class,
          where: s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    IO.puts("finish list class data")

    student_big_data =
      Repo.all(
        from(
          s in School.Affairs.Student,
          left_join: g in School.Affairs.StudentClass,
          on: s.id == g.sudent_id,
          left_join: k in School.Affairs.Class,
          on: k.id == g.class_id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              g.semester_id == ^conn.private.plug_session["semester_id"],
          # g.class_id == ^item.id,
          select: %{
            student_id: s.id,
            student_name: s.name,
            chinese_name: s.chinese_name,
            class_name: k.name,
            class_id: g.class_id
          }
        )
      )

    IO.puts("finish student big data")

    for item <- list_class_data do
      class_info = item
      list_class = list_class_data |> Enum.filter(fn x -> x.level_id == item.level_id end)

      all_student =
        for item <- list_class do
          student_big_data |> Enum.filter(fn x -> x.class_id == item.id end)
        end
        |> List.flatten()
        |> Enum.uniq()
        |> Enum.count()

      IO.puts("class start #{item.name}")
      student_class = student_class_data |> Enum.filter(fn x -> x.class_id == item.id end)
      list_exam = list_exam_data |> Enum.filter(fn x -> x.level_id == item.level_id end)

      Task.start_link(__MODULE__, :task_generate_report_card_temp, [
        # batch, batch_params, bin, cur_user

        # SchoolWeb.PdfController.task_generate_report_card_temp(
        conn,
        params,
        item.name,
        conn.private.plug_session["semester_id"],
        list_class,
        all_student,
        semester,
        institute,
        subject,
        student_class,
        list_exam,
        exam_big_data
      ])

      # )
    end

    conn
    |> put_flash(:info, "running...")
    |> redirect(to: page_path(conn, :support_dashboard))
  end

  def task_generate_report_card_temp(
        conn,
        params,
        class_name,
        semester_id,
        list_class,
        all_student,
        semester,
        institute,
        subject,
        student_class,
        list_exam,
        exam_big_data
      ) do
    class_info = list_class |> Enum.filter(fn x -> x.name == class_name end) |> hd()

    result =
      for stud_class <- student_class do
        for item <- subject do
          all =
            exam_big_data
            |> Enum.filter(fn x -> x.class_name == class_info.name end)
            |> Enum.filter(fn x -> x.em_subject_id == item.id end)
            |> Enum.filter(fn x -> x.em_student_id == stud_class.student_id end)
            |> Enum.filter(fn x -> x != nil end)
            |> Enum.sort()

          {mark, grade} =
            if item.with_mark == 1 do
              mark =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      if a.mark != nil do
                        a.mark |> Decimal.to_string()
                      else
                        "0"
                      end
                    end

                  {no + 1, fit}
                end

              grade =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      mark =
                        if a.mark != nil do
                          a.mark |> Decimal.to_float()
                        else
                          0
                        end

                      grades =
                        Repo.all(
                          from(
                            g in School.Affairs.ExamGrade,
                            where:
                              g.institution_id == ^conn.private.plug_session["institution_id"] and
                                g.exam_master_id == ^a.exam_master_id
                          )
                        )

                      grade =
                        if mark != 0 do
                          for grade <- grades do
                            if mark >= Decimal.to_float(grade.min) and
                                 mark <= Decimal.to_float(grade.max) do
                              grade.name
                            end
                          end
                          |> Enum.filter(fn x -> x != nil end)
                          |> hd
                        else
                          "E"
                        end
                    end

                  {no + 1, fit}
                end

              {mark, grade}
            else
              mark =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      "0"
                    end

                  {no + 1, fit}
                end

              grade =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      grade =
                        if a.grade == nil do
                          ""
                        else
                          a.grade
                        end

                      grades = grade
                    end

                  {no + 1, fit}
                end

              {mark, grade}
            end

          finish =
            if all != [] do
              all = all |> hd

              subject =
                Repo.get_by(
                  School.Affairs.Subject,
                  code: all.subject_code,
                  institution_id: conn.private.plug_session["institution_id"]
                )

              absent =
                Repo.get_by(
                  School.Affairs.ExamAttendance,
                  student_id: all.student_id,
                  semester_id: semester.id,
                  institution_id: conn.private.plug_session["institution_id"],
                  exam_master_id: all.exam_master_id,
                  subject_id: subject.id
                )

              count = mark |> Enum.count()

              {s1m, s2m, s3m, s1g, s2g, s3g} =
                if count == 1 do
                  s1m = mark |> Enum.fetch!(0) |> elem(1)
                  s2m = ""
                  s3m = ""

                  s1g =
                    if absent != nil do
                      "TH"
                    else
                      grade |> Enum.fetch!(0) |> elem(1)
                    end

                  s2g = ""
                  s3g = ""

                  {s1m, s2m, s3m, s1g, s2g, s3g}
                else
                  if count == 2 do
                    s1m = mark |> Enum.fetch!(0) |> elem(1)
                    s2m = mark |> Enum.fetch!(1) |> elem(1)
                    s3m = ""

                    s1g =
                      if absent != nil do
                        "TH"
                      else
                        grade |> Enum.fetch!(0) |> elem(1)
                      end

                    s2g =
                      if absent != nil do
                        "TH"
                      else
                        grade |> Enum.fetch!(1) |> elem(1)
                      end

                    s3g = ""
                    {s1m, s2m, s3m, s1g, s2g, s3g}
                  else
                    if count == 3 do
                      s1m = mark |> Enum.fetch!(0) |> elem(1)
                      s2m = mark |> Enum.fetch!(1) |> elem(1)
                      s3m = mark |> Enum.fetch!(2) |> elem(1)

                      s1g =
                        if absent != nil do
                          "TH"
                        else
                          grade |> Enum.fetch!(0) |> elem(1)
                        end

                      s2g =
                        if absent != nil do
                          "TH"
                        else
                          grade |> Enum.fetch!(1) |> elem(1)
                        end

                      s3g =
                        if absent != nil do
                          "TH"
                        else
                          grade |> Enum.fetch!(2) |> elem(1)
                        end

                      {s1m, s2m, s3m, s1g, s2g, s3g}
                    end
                  end
                end

              %{
                institution_id: conn.private.plug_session["institution_id"],
                stuid: all.student_id |> Integer.to_string(),
                name: all.student_name,
                cname: all.chinese_name,
                class: all.class_name,
                subject: all.subject_code,
                description: all.subject_name,
                year: all.year |> Integer.to_string(),
                semester: all.semester_no |> Integer.to_string(),
                s1m: s1m,
                s2m: s2m,
                s3m: s3m,
                s1g: s1g,
                s2g: s2g,
                s3g: s3g
              }
            end

          finish
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    class_rank =
      for stud_class <- student_class do
        all = exam_big_data |> Enum.filter(fn x -> x.em_student_id == stud_class.student_id end)

        all_result =
          exam_big_data
          |> Enum.filter(fn x -> x.class_name == class_info.name end)
          |> Enum.filter(fn x -> x.sb_with_mark == 1 end)

        total_mark =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all_result |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            drg =
              if fit == [] do
                []
              else
                fit = fit |> Enum.group_by(fn x -> x.student_id end)

                data =
                  for items <- fit do
                    student_id = items |> elem(0)
                    items = items |> elem(1)

                    a =
                      case conn.private.plug_session["institution_id"] do
                        9 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          fail =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x ->
                              Decimal.to_float(x.mark) >= 1 and Decimal.to_float(x.mark) <= 39.9
                            end)

                          fail =
                            if fail != [] do
                              true
                            else
                              false
                            end

                          th =
                            if absent != [] do
                              true
                            else
                              false
                            end

                          if items != [] do
                            item = items |> hd

                            %{
                              student_id: item.student_id,
                              student_name: item.student_name,
                              chinese_name: item.chinese_name,
                              class_name: item.class_name,
                              exam_master_id: item.exam_master_id,
                              exam_name: item.exam_name,
                              semester: item.semester,
                              semester_no: item.semester_no,
                              year: item.year,
                              subject_code: "CRank",
                              subject_name: "Class Rank",
                              subject_cname: "Class Rank",
                              t_grade: "t_grade",
                              th: th,
                              fail: fail,
                              total_mark: sum,
                              standard_id: item.standard_id
                            }
                          end

                        10 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          a =
                            if absent == [] do
                              sum =
                                items
                                |> Enum.filter(fn x -> x.mark != 0 end)
                                |> Enum.filter(fn x -> x.mark != nil end)
                                |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                                |> Enum.sum()

                              if items != [] do
                                item = items |> hd

                                %{
                                  student_id: item.student_id,
                                  student_name: item.student_name,
                                  chinese_name: item.chinese_name,
                                  class_name: item.class_name,
                                  exam_master_id: item.exam_master_id,
                                  exam_name: item.exam_name,
                                  semester: item.semester,
                                  semester_no: item.semester_no,
                                  year: item.year,
                                  subject_code: "CRank",
                                  subject_name: "Class Rank",
                                  subject_cname: "Class Rank",
                                  t_grade: "",
                                  total_mark: sum,
                                  standard_id: item.standard_id
                                }
                              end
                            else
                            end

                        3 ->
                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "CRank",
                                subject_name: "Class Rank",
                                subject_cname: "Class Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end

                        _ ->
                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "CRank",
                                subject_name: "Class Rank",
                                subject_cname: "Class Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end
                      end

                    a
                  end
                  |> Enum.filter(fn x -> x != nil end)

                data =
                  case conn.private.plug_session["institution_id"] do
                    9 ->
                      data2 =
                        data
                        |> Enum.filter(fn x -> x.fail == true and x.th == false end)
                        |> Enum.uniq()
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      data3 =
                        data
                        |> Enum.filter(fn x -> x.th == true and x.fail == false end)
                        |> Enum.uniq()
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      data4 =
                        data
                        |> Enum.filter(fn x -> x.th == true and x.fail == true end)
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      all_p =
                        (data -- (data2 ++ data3 ++ data4))
                        |> Enum.uniq()
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      data = all_p ++ data2 ++ data3 ++ data4

                      data
                      |> School.assign_rank()
                      |> Enum.map(fn x -> {elem(x, 0), elem(x, 1) - 2} end)
                      |> Enum.drop(1)

                    3 ->
                      data
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()
                      |> Enum.with_index()

                    _ ->
                      data
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()
                      |> Enum.with_index()
                  end

                data
              end

            end_fit =
              for item <- drg do
                if item != [] do
                  no = item |> elem(1)
                  item = item |> elem(0)

                  total = student_class |> Enum.count() |> Integer.to_string()

                  rank = no + 1
                  rank = rank |> Integer.to_string()

                  %{
                    student_id: item.student_id,
                    student_name: item.student_name,
                    chinese_name: item.chinese_name,
                    class_name: item.class_name,
                    exam_master_id: item.exam_master_id,
                    exam_name: item.exam_name,
                    semester: item.semester,
                    semester_no: item.semester_no,
                    year: item.year,
                    subject_code: "CRank",
                    subject_name: "Class Rank",
                    subject_cname: "Class Rank",
                    rank: rank <> "/" <> total,
                    standard_id: item.standard_id
                  }
                else
                  []
                end
              end

            defit = end_fit |> Enum.filter(fn x -> x.student_id == stud_class.student_id end)

            desfit =
              if defit == [] do
                ""
              else
                a = defit |> hd

                a.rank
              end

            {no + 1, desfit}
          end

        finish_rank =
          if all != [] do
            all = all |> hd

            count = total_mark |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                  s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                    s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                    s3m = total_mark |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  else
                    IO.inspect("got more than 3 at line 894, class #{class_name}")
                    s1m = ""
                    s2m = ""
                    s3m = ""
                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "CRANK",
              description: "Class Rank",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_rank
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    standard_rank =
      for stud_class <- student_class do
        all =
          exam_big_data
          |> Enum.filter(fn x -> x.class_name == class_info.name end)
          |> Enum.filter(fn x -> x.em_student_id == stud_class.student_id end)

        all_result =
          exam_big_data
          |> Enum.filter(fn x -> x.e_level_id == class_info.level_id end)
          |> Enum.filter(fn x -> x.sb_with_mark == 1 end)

        total_mark =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all_result |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            drg =
              if fit == [] do
                []
              else
                fit = fit |> Enum.group_by(fn x -> x.student_id end)

                data =
                  for items <- fit do
                    student_id = items |> elem(0)
                    items = items |> elem(1)

                    a =
                      case conn.private.plug_session["institution_id"] do
                        9 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          fail =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x ->
                              Decimal.to_float(x.mark) >= 1 and Decimal.to_float(x.mark) <= 39.9
                            end)

                          fail =
                            if fail != [] do
                              true
                            else
                              false
                            end

                          th =
                            if absent != [] do
                              true
                            else
                              false
                            end

                          if items != [] do
                            item = items |> hd

                            %{
                              student_id: item.student_id,
                              student_name: item.student_name,
                              chinese_name: item.chinese_name,
                              class_name: item.class_name,
                              exam_master_id: item.exam_master_id,
                              exam_name: item.exam_name,
                              semester: item.semester,
                              semester_no: item.semester_no,
                              year: item.year,
                              subject_code: "Standard",
                              subject_name: "Standard Rank",
                              subject_cname: "Standard Rank",
                              fail: fail,
                              th: th,
                              total_mark: sum,
                              standard_id: item.standard_id
                            }
                          end

                        10 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          a =
                            if absent == [] do
                              sum =
                                items
                                |> Enum.filter(fn x -> x.mark != nil end)
                                |> Enum.filter(fn x -> x.mark != 0 end)
                                |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                                |> Enum.sum()

                              if items != [] do
                                item = items |> hd

                                %{
                                  student_id: item.student_id,
                                  student_name: item.student_name,
                                  chinese_name: item.chinese_name,
                                  class_name: item.class_name,
                                  exam_master_id: item.exam_master_id,
                                  exam_name: item.exam_name,
                                  semester: item.semester,
                                  semester_no: item.semester_no,
                                  year: item.year,
                                  subject_code: "Standard",
                                  subject_name: "Standard Rank",
                                  subject_cname: "Standard Rank",
                                  t_grade: "",
                                  total_mark: sum,
                                  standard_id: item.standard_id
                                }
                              end
                            else
                            end

                        3 ->
                          coming = items |> hd

                          # absent =
                          #   Repo.get_by(
                          #     School.Affairs.ExamAttendance,
                          #     student_id: coming.student_id,
                          #     semester_id: coming.semester,
                          #     institution_id: conn.private.plug_session["institution_id"],
                          #     exam_master_id: coming.exam_master_id
                          #   )

                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "Standard",
                                subject_name: "Standard Rank",
                                subject_cname: "Standard Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end

                        _ ->
                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "Standard",
                                subject_name: "Standard Rank",
                                subject_cname: "Standard Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end
                      end
                  end
                  |> Enum.filter(fn x -> x != nil end)

                data =
                  if conn.private.plug_session["institution_id"] == 9 do
                    data2 =
                      data
                      |> Enum.filter(fn x -> x.fail == true and x.th == false end)
                      |> Enum.uniq()
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    data3 =
                      data
                      |> Enum.filter(fn x -> x.th == true and x.fail == false end)
                      |> Enum.uniq()
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    data4 =
                      data
                      |> Enum.filter(fn x -> x.th == true and x.fail == true end)
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    all_p =
                      (data -- (data2 ++ data3 ++ data4))
                      |> Enum.uniq()
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    data = all_p ++ data2 ++ data3 ++ data4

                    data
                    |> School.assign_rank()
                    |> Enum.map(fn x -> {elem(x, 0), elem(x, 1) - 2} end)
                    |> Enum.drop(1)
                  else
                    data
                    |> Enum.sort_by(fn x -> x.total_mark end)
                    |> Enum.reverse()
                    |> Enum.with_index()
                  end

                data
              end

            end_fit =
              for item <- drg do
                if item != [] do
                  no = item |> elem(1)
                  item = item |> elem(0)

                  total =
                    case conn.private.plug_session["institution_id"] do
                      9 ->
                        absent =
                          Repo.all(
                            from(
                              s in School.Affairs.ExamAttendance,
                              left_join: k in School.Affairs.StudentClass,
                              on: s.student_id == k.sudent_id,
                              where:
                                k.level_id == ^class_info.level_id and
                                  s.semester_id == ^conn.private.plug_session["semester_id"] and
                                  k.institute_id == ^conn.private.plug_session["institution_id"] and
                                  s.exam_master_id == ^item.exam_master_id
                            )
                          )
                          |> Enum.uniq()
                          |> Enum.count()

                        total = all_student - absent

                      10 ->
                        absent =
                          Repo.all(
                            from(
                              s in School.Affairs.ExamAttendance,
                              left_join: k in School.Affairs.StudentClass,
                              on: s.student_id == k.sudent_id,
                              where:
                                k.level_id == ^class_info.level_id and
                                  s.semester_id == ^conn.private.plug_session["semester_id"] and
                                  k.institute_id == ^conn.private.plug_session["institution_id"] and
                                  s.exam_master_id == ^item.exam_master_id
                            )
                          )
                          |> Enum.uniq()
                          |> Enum.count()

                        IO.inspect("all_student#{all_student}")
                        IO.inspect("total_absent#{absent}")

                        total = all_student - absent

                      3 ->
                        total = all_student

                      _ ->
                        all_student =
                          Repo.all(
                            from(
                              sc in School.Affairs.StudentClass,
                              where:
                                sc.level_id == ^class_info.level_id and
                                  sc.semester_id == ^conn.private.plug_session["semester_id"] and
                                  sc.institute_id == ^conn.private.plug_session["institution_id"]
                            )
                          )
                          |> Enum.uniq()
                          |> Enum.count()

                        total = all_student
                    end

                  total =
                    if conn.private.plug_session["institution_id"] == 10 do
                      total |> Integer.to_string()
                    else
                      all_student |> Integer.to_string()
                    end

                  rank = no + 1
                  rank = rank |> Integer.to_string()

                  item = item

                  %{
                    student_id: item.student_id,
                    student_name: item.student_name,
                    chinese_name: item.chinese_name,
                    class_name: item.class_name,
                    exam_master_id: item.exam_master_id,
                    exam_name: item.exam_name,
                    semester: item.semester,
                    semester_no: item.semester_no,
                    year: item.year,
                    subject_code: "Standard",
                    subject_name: "Standard Rank",
                    subject_cname: "Standard Rank",
                    rank: rank <> "/" <> total,
                    standard_id: item.standard_id
                  }
                else
                  []
                end
              end

            defit = end_fit |> Enum.filter(fn x -> x.student_id == stud_class.student_id end)

            desfit =
              if defit == [] do
                ""
              else
                a = defit |> hd

                a.rank
              end

            {no + 1, desfit}
          end

        finish_rank =
          if all != [] do
            all = all |> hd

            count = total_mark |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                  s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                    s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                    s3m = total_mark |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "SRANK",
              description: "Standard Rank",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_rank
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    total_markfinish =
      for stud_class <- student_class do
        all =
          exam_big_data
          |> Enum.filter(fn x -> x.class_name == class_info.name end)
          |> Enum.filter(fn x -> x.student_id == stud_class.student_id end)
          |> Enum.filter(fn x -> x.sb_with_mark == 1 end)

        total_mark =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            fit =
              if fit == [] do
                ""
              else
                list =
                  case conn.private.plug_session["institution_id"] do
                    9 ->
                      list =
                        for item <- fit do
                          # subject =
                          #   Repo.get_by(
                          #     School.Affairs.Subject,
                          #     code: item.subject_code,
                          #     institution_id: conn.private.plug_session["institution_id"]
                          #   )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id
                              )
                            )

                          %{
                            student_id: item.student_id,
                            student_name: item.student_name,
                            chinese_name: item.chinese_name,
                            class_name: item.class_name,
                            exam_master_id: item.exam_master_id,
                            exam_name: item.exam_name,
                            semester: item.semester,
                            semester_no: item.semester_no,
                            year: item.year,
                            subject_code: item.subject_code,
                            subject_name: item.subject_name,
                            subject_cname: item.subject_cname,
                            mark: item.mark,
                            absent: absent |> Enum.count(),
                            standard_id: item.standard_id
                          }
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    10 ->
                      list =
                        for item <- fit do
                          subject =
                            Repo.get_by(
                              School.Affairs.Subject,
                              code: item.subject_code,
                              institution_id: conn.private.plug_session["institution_id"]
                            )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id and
                                    s.subject_id == ^subject.id
                              )
                            )

                          a =
                            if absent == [] do
                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: item.subject_code,
                                subject_name: item.subject_name,
                                subject_cname: item.subject_cname,
                                mark: item.mark,
                                standard_id: item.standard_id
                              }
                            end
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    3 ->
                      list = fit

                    _ ->
                      list = fit
                  end

                total_absent =
                  if conn.private.plug_session["institution_id"] == 9 do
                    a =
                      list
                      |> Enum.map(fn x -> x.absent end)
                      |> Enum.uniq()

                    if a == [] do
                      0
                    else
                      a |> hd
                    end
                  end

                a =
                  list
                  |> Enum.filter(fn x -> x.mark != 0 end)
                  |> Enum.filter(fn x -> x.mark != nil end)
                  |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                  |> Enum.sum()

                # per_th = list |> Enum.filter(fn x -> x.mark == nil end) |> Enum.count()

                per = list |> Enum.map(fn x -> x.subject_code end) |> Enum.uniq() |> Enum.count()
                IO.inspect("per, #{per}")

                IO.inspect("total_absent, #{total_absent}")

                per =
                  if list |> Enum.any?(fn x -> x.subject_code == "AGM" end) do
                    per = per - 1 - total_absent
                    # per = per - 1 + per_th
                  else
                    per = per - total_absent
                    # per = per + per_th
                  end

                total_per = per * 100
                total_per = total_per |> Integer.to_string()

                a =
                  if a == 0.0 do
                    "0" <> "/" <> total_per
                  else
                    a = a |> Float.round(2) |> Float.to_string()

                    a <> "/" <> total_per
                  end
              end

            {no + 1, fit}
          end

        finish_total_mark =
          if all != [] do
            all = all |> hd

            count = total_mark |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                  s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                    s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                    s3m = total_mark |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "TOTAL",
              description: "Total Mark Each Exam",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_total_mark
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    total_purata =
      for stud_class <- student_class do
        all =
          exam_big_data
          |> Enum.filter(fn x -> x.class_name == class_info.name end)
          |> Enum.filter(fn x -> x.student_id == stud_class.student_id end)
          |> Enum.filter(fn x -> x.sb_with_mark == 1 end)

        total_average =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            fit =
              if fit == [] do
                ""
              else
                list =
                  case conn.private.plug_session["institution_id"] do
                    9 ->
                      list =
                        for item <- fit do
                          subject =
                            Repo.get_by(
                              School.Affairs.Subject,
                              code: item.subject_code,
                              institution_id: conn.private.plug_session["institution_id"]
                            )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id
                              )
                            )

                          %{
                            student_id: item.student_id,
                            student_name: item.student_name,
                            chinese_name: item.chinese_name,
                            class_name: item.class_name,
                            exam_master_id: item.exam_master_id,
                            exam_name: item.exam_name,
                            semester: item.semester,
                            semester_no: item.semester_no,
                            year: item.year,
                            subject_code: item.subject_code,
                            subject_name: item.subject_name,
                            subject_cname: item.subject_cname,
                            mark: item.mark,
                            absent: absent |> Enum.count(),
                            standard_id: item.standard_id
                          }
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    10 ->
                      list =
                        for item <- fit do
                          subject =
                            Repo.get_by(
                              School.Affairs.Subject,
                              code: item.subject_code,
                              institution_id: conn.private.plug_session["institution_id"]
                            )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id
                              )
                            )

                          a =
                            if absent == [] do
                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: item.subject_code,
                                subject_name: item.subject_name,
                                subject_cname: item.subject_cname,
                                mark: item.mark,
                                absent: absent |> Enum.count(),
                                standard_id: item.standard_id
                              }
                            end
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    3 ->
                      list = fit

                    _ ->
                      list = fit
                  end

                a =
                  list
                  |> Enum.filter(fn x -> x.mark != 0 end)
                  |> Enum.filter(fn x -> x.mark != nil end)
                  |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                  |> Enum.sum()

                total_absent =
                  if conn.private.plug_session["institution_id"] == 9 do
                    absent_data =
                      list
                      |> Enum.map(fn x -> x.absent end)
                      |> Enum.uniq()

                    if absent_data == [] do
                      0
                    else
                      absent_data |> hd
                    end
                  end

                per = list |> Enum.map(fn x -> x.subject_code end) |> Enum.uniq() |> Enum.count()

                per =
                  if list |> Enum.any?(fn x -> x.subject_code == "AGM" end) do
                    per = per - 1 - total_absent
                  else
                    per = per - total_absent
                  end

                total_per = per * 100

                total_average =
                  if total_per != 0 do
                    a / total_per * 100
                  else
                    0
                  end

                total_average =
                  if total_average != 0 do
                    total_average |> Float.round(2) |> Float.to_string()
                  else
                    0
                  end
              end

            {no + 1, fit}
          end

        finish_total_mark =
          if all != [] do
            all = all |> hd

            count = total_average |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_average |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_average |> Enum.fetch!(0) |> elem(1)
                  s2m = total_average |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_average |> Enum.fetch!(0) |> elem(1)
                    s2m = total_average |> Enum.fetch!(1) |> elem(1)
                    s3m = total_average |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "AVERG",
              description: "Total Average Each Exam",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_total_mark
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    total_h_w =
      for stud_class <- student_class do
        all =
          exam_big_data
          |> Enum.filter(fn x -> x.class_name == class_info.name end)
          |> Enum.filter(fn x -> x.student_id == stud_class.student_id end)

        total_hei_wei =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all |> Enum.filter(fn x -> x.semester == exam.semester_id end)

            fit =
              if fit == [] do
                ""
              else
                a = fit |> hd

                student = Repo.get_by(School.Affairs.Student, id: a.student_id)

                data = student.height
                data2 = student.weight

                heig =
                  if data != nil do
                    data = data |> String.split(",")

                    hg =
                      for item <- data do
                        item = item |> String.split("-")

                        height = item |> Enum.fetch!(1)

                        semester = item |> Enum.fetch!(0)

                        {semester, height}
                      end

                    last =
                      hg
                      |> Enum.filter(fn x ->
                        x |> elem(0) == Integer.to_string(exam.semester_id)
                      end)
                      |> hd

                    last = last |> elem(1)
                  else
                    ""
                  end

                last_hg = heig

                weig =
                  if data2 != nil do
                    data2 = data2 |> String.split(",")

                    hg =
                      for item2 <- data2 do
                        item2 = item2 |> String.split("-")
                        weight = item2 |> Enum.fetch!(1)
                        semester = item2 |> Enum.fetch!(0)

                        {semester, weight}
                      end

                    last2 =
                      hg
                      |> Enum.filter(fn x ->
                        x |> elem(0) == Integer.to_string(exam.semester_id)
                      end)
                      |> hd

                    last2 = last2 |> elem(1)
                  else
                    ""
                  end

                last_wg = weig

                last_hg <> "CM" <> " , " <> last_wg <> "KG"
              end

            {no + 1, fit}
          end

        total_height_weight =
          if all != [] do
            all = all |> hd

            count = total_hei_wei |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_hei_wei |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_hei_wei |> Enum.fetch!(0) |> elem(1)
                  s2m = total_hei_wei |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_hei_wei |> Enum.fetch!(0) |> elem(1)
                    s2m = total_hei_wei |> Enum.fetch!(1) |> elem(1)
                    s3m = total_hei_wei |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "H&W",
              description: "Height and Weight",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        total_height_weight
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    result =
      result ++ class_rank ++ standard_rank ++ total_markfinish ++ total_purata ++ total_h_w

    exist =
      Repo.all(
        from(
          s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem)
        )
      )

    if exist != [] do
      Repo.delete_all(
        from(
          s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem)
        )
      )

      for item <- result do
        Affairs.create_mark_sheet_temp(item)
      end

      IO.puts("Mark sheet temp created successfully.")
    else
      for item <- result do
        Affairs.create_mark_sheet_temp(item)
      end

      IO.puts("Mark sheet temp created successfully.")
    end
  end

  def report_card_temp(conn, params) do
    class_name = params["class"]
    semester_id = params["semester"]

    class_info =
      Repo.get_by(
        School.Affairs.Class,
        name: class_name,
        institution_id: conn.private.plug_session["institution_id"]
      )

    list_class =
      Repo.all(
        from(
          s in School.Affairs.Class,
          where:
            s.level_id == ^class_info.level_id and
              s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    all_student =
      for item <- list_class do
        student_class =
          Repo.all(
            from(
              s in School.Affairs.Student,
              left_join: g in School.Affairs.StudentClass,
              on: s.id == g.sudent_id,
              left_join: k in School.Affairs.Class,
              on: k.id == g.class_id,
              where:
                s.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.semester_id == ^conn.private.plug_session["semester_id"] and
                  g.class_id == ^item.id,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: k.name
              }
            )
          )
      end
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.count()

    semester = Repo.get_by(School.Affairs.Semester, id: semester_id)

    institute =
      Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

    subject =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          where: s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    student_class =
      Repo.all(
        from(
          s in School.Affairs.Student,
          left_join: g in School.Affairs.StudentClass,
          on: s.id == g.sudent_id,
          left_join: k in School.Affairs.Class,
          on: k.id == g.class_id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              g.semester_id == ^conn.private.plug_session["semester_id"] and
              g.class_id == ^class_info.id,
          select: %{
            student_id: s.id,
            student_name: s.name,
            chinese_name: s.chinese_name,
            class_name: k.name
          }
        )
      )

    list_exam =
      Repo.all(
        from(
          s in School.Affairs.ExamMaster,
          where:
            s.level_id == ^class_info.level_id and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^semester_id
        )
      )
      |> Enum.sort()

    result =
      for stud_class <- student_class do
        for item <- subject do
          all =
            Repo.all(
              from(
                em in School.Affairs.ExamMark,
                left_join: z in School.Affairs.Exam,
                on: em.exam_id == z.id,
                left_join: e in School.Affairs.ExamMaster,
                on: z.exam_master_id == e.id,
                left_join: j in School.Affairs.Semester,
                on: e.semester_id == j.id,
                left_join: s in School.Affairs.Student,
                on: em.student_id == s.id,
                left_join: sc in School.Affairs.StudentClass,
                on: sc.sudent_id == s.id,
                left_join: c in School.Affairs.Class,
                on: sc.class_id == c.id,
                left_join: sb in School.Affairs.Subject,
                on: em.subject_id == sb.id,
                where:
                  c.name == ^class_name and sc.semester_id == ^semester_id and
                    em.subject_id == ^item.id and em.student_id == ^stud_class.student_id,
                select: %{
                  student_id: s.id,
                  student_name: s.name,
                  chinese_name: s.chinese_name,
                  class_name: c.name,
                  exam_master_id: e.id,
                  exam_name: e.name,
                  semester: j.id,
                  semester_no: j.sem,
                  year: j.year,
                  subject_code: sb.code,
                  subject_name: sb.description,
                  subject_cname: sb.cdesc,
                  mark: em.mark,
                  grade: em.grade,
                  standard_id: sc.level_id
                }
              )
            )
            |> Enum.filter(fn x -> x != nil end)
            |> Enum.sort()

          {mark, grade} =
            if item.with_mark == 1 do
              mark =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      if a.mark != nil do
                        a.mark |> Decimal.to_string()
                      else
                        "0"
                      end
                    end

                  {no + 1, fit}
                end

              grade =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      mark =
                        if a.mark != nil do
                          a.mark |> Decimal.to_float()
                        else
                          0
                        end

                      grades =
                        Repo.all(
                          from(
                            g in School.Affairs.ExamGrade,
                            where:
                              g.institution_id == ^conn.private.plug_session["institution_id"] and
                                g.exam_master_id == ^a.exam_master_id
                          )
                        )

                      grade =
                        if mark != 0 do
                          for grade <- grades do
                            if mark >= Decimal.to_float(grade.min) and
                                 mark <= Decimal.to_float(grade.max) do
                              grade.name
                            end
                          end
                          |> Enum.filter(fn x -> x != nil end)
                          |> hd
                        else
                          "E"
                        end
                    end

                  {no + 1, fit}
                end

              {mark, grade}
            else
              mark =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      "0"
                    end

                  {no + 1, fit}
                end

              grade =
                for exam <- list_exam |> Enum.with_index() do
                  no = exam |> elem(1)
                  exam = exam |> elem(0)

                  fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

                  fit =
                    if fit == [] do
                      ""
                    else
                      a = fit |> hd()

                      grade =
                        if a.grade == nil do
                          ""
                        else
                          a.grade
                        end

                      grades = grade
                    end

                  {no + 1, fit}
                end

              {mark, grade}
            end

          finish =
            if all != [] do
              all = all |> hd

              subject =
                Repo.get_by(
                  School.Affairs.Subject,
                  code: all.subject_code,
                  institution_id: conn.private.plug_session["institution_id"]
                )

              absent =
                Repo.get_by(
                  School.Affairs.ExamAttendance,
                  student_id: all.student_id,
                  semester_id: semester.id,
                  institution_id: conn.private.plug_session["institution_id"],
                  exam_master_id: all.exam_master_id,
                  subject_id: subject.id
                )

              count = mark |> Enum.count()

              {s1m, s2m, s3m, s1g, s2g, s3g} =
                if count == 1 do
                  s1m = mark |> Enum.fetch!(0) |> elem(1)
                  s2m = ""
                  s3m = ""

                  s1g =
                    if absent != nil do
                      "TH"
                    else
                      grade |> Enum.fetch!(0) |> elem(1)
                    end

                  s2g = ""
                  s3g = ""

                  {s1m, s2m, s3m, s1g, s2g, s3g}
                else
                  if count == 2 do
                    s1m = mark |> Enum.fetch!(0) |> elem(1)
                    s2m = mark |> Enum.fetch!(1) |> elem(1)
                    s3m = ""

                    s1g =
                      if absent != nil do
                        "TH"
                      else
                        grade |> Enum.fetch!(0) |> elem(1)
                      end

                    s2g =
                      if absent != nil do
                        "TH"
                      else
                        grade |> Enum.fetch!(1) |> elem(1)
                      end

                    s3g = ""
                    {s1m, s2m, s3m, s1g, s2g, s3g}
                  else
                    if count == 3 do
                      s1m = mark |> Enum.fetch!(0) |> elem(1)
                      s2m = mark |> Enum.fetch!(1) |> elem(1)
                      s3m = mark |> Enum.fetch!(2) |> elem(1)

                      s1g =
                        if absent != nil do
                          "TH"
                        else
                          grade |> Enum.fetch!(0) |> elem(1)
                        end

                      s2g =
                        if absent != nil do
                          "TH"
                        else
                          grade |> Enum.fetch!(1) |> elem(1)
                        end

                      s3g =
                        if absent != nil do
                          "TH"
                        else
                          grade |> Enum.fetch!(2) |> elem(1)
                        end

                      {s1m, s2m, s3m, s1g, s2g, s3g}
                    end
                  end
                end

              %{
                institution_id: conn.private.plug_session["institution_id"],
                stuid: all.student_id |> Integer.to_string(),
                name: all.student_name,
                cname: all.chinese_name,
                class: all.class_name,
                subject: all.subject_code,
                description: all.subject_name,
                year: all.year |> Integer.to_string(),
                semester: all.semester_no |> Integer.to_string(),
                s1m: s1m,
                s2m: s2m,
                s3m: s3m,
                s1g: s1g,
                s2g: s2g,
                s3g: s3g
              }
            end

          finish
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    class_rank =
      for stud_class <- student_class do
        all =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                c.name == ^class_name and em.student_id == ^stud_class.student_id and
                  sc.semester_id == ^semester_id,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                semester_no: j.sem,
                year: j.year,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                grade: em.grade,
                standard_id: sc.level_id
              }
            )
          )

        all_result =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                c.name == ^class_name and sc.semester_id == ^semester_id and sb.with_mark == 1,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                semester_no: j.sem,
                year: j.year,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                grade: em.grade,
                standard_id: sc.level_id
              }
            )
          )

        total_mark =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all_result |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            drg =
              if fit == [] do
                []
              else
                fit = fit |> Enum.group_by(fn x -> x.student_id end)

                data =
                  for items <- fit do
                    student_id = items |> elem(0)
                    items = items |> elem(1)

                    a =
                      case conn.private.plug_session["institution_id"] do
                        9 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          fail =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x ->
                              Decimal.to_float(x.mark) >= 1 and Decimal.to_float(x.mark) <= 39.9
                            end)

                          fail =
                            if fail != [] do
                              true
                            else
                              false
                            end

                          th =
                            if absent != [] do
                              true
                            else
                              false
                            end

                          if items != [] do
                            item = items |> hd

                            %{
                              student_id: item.student_id,
                              student_name: item.student_name,
                              chinese_name: item.chinese_name,
                              class_name: item.class_name,
                              exam_master_id: item.exam_master_id,
                              exam_name: item.exam_name,
                              semester: item.semester,
                              semester_no: item.semester_no,
                              year: item.year,
                              subject_code: "CRank",
                              subject_name: "Class Rank",
                              subject_cname: "Class Rank",
                              t_grade: "t_grade",
                              th: th,
                              fail: fail,
                              total_mark: sum,
                              standard_id: item.standard_id
                            }
                          end

                        10 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          a =
                            if absent == [] do
                              sum =
                                items
                                |> Enum.filter(fn x -> x.mark != 0 end)
                                |> Enum.filter(fn x -> x.mark != nil end)
                                |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                                |> Enum.sum()

                              if items != [] do
                                item = items |> hd

                                %{
                                  student_id: item.student_id,
                                  student_name: item.student_name,
                                  chinese_name: item.chinese_name,
                                  class_name: item.class_name,
                                  exam_master_id: item.exam_master_id,
                                  exam_name: item.exam_name,
                                  semester: item.semester,
                                  semester_no: item.semester_no,
                                  year: item.year,
                                  subject_code: "CRank",
                                  subject_name: "Class Rank",
                                  subject_cname: "Class Rank",
                                  t_grade: "",
                                  total_mark: sum,
                                  standard_id: item.standard_id
                                }
                              end
                            else
                            end

                        3 ->
                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "CRank",
                                subject_name: "Class Rank",
                                subject_cname: "Class Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end

                        _ ->
                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "CRank",
                                subject_name: "Class Rank",
                                subject_cname: "Class Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end
                      end

                    a
                  end
                  |> Enum.filter(fn x -> x != nil end)

                data =
                  case conn.private.plug_session["institution_id"] do
                    9 ->
                      data2 =
                        data
                        |> Enum.filter(fn x -> x.fail == true and x.th == false end)
                        |> Enum.uniq()
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      data3 =
                        data
                        |> Enum.filter(fn x -> x.th == true and x.fail == false end)
                        |> Enum.uniq()
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      data4 =
                        data
                        |> Enum.filter(fn x -> x.th == true and x.fail == true end)
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      all_p =
                        (data -- (data2 ++ data3 ++ data4))
                        |> Enum.uniq()
                        |> Enum.sort_by(fn x -> x.total_mark end)
                        |> Enum.reverse()

                      data = all_p ++ data2 ++ data3 ++ data4

                      data
                      |> School.assign_rank()
                      |> Enum.map(fn x -> {elem(x, 0), elem(x, 1) - 2} end)
                      |> Enum.drop(1)

                    3 ->
                      data
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()
                      |> Enum.with_index()

                    _ ->
                      data
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()
                      |> Enum.with_index()
                  end

                data
              end

            end_fit =
              for item <- drg do
                if item != [] do
                  no = item |> elem(1)
                  item = item |> elem(0)

                  total =
                    if conn.private.plug_session["institution_id"] != 10 do
                      student_class |> Enum.count() |> Integer.to_string()
                    else
                      class =
                        Repo.get_by(School.Affairs.Class, %{
                          name: item.class_name,
                          institution_id: conn.private.plug_session["institution_id"]
                        })

                      absent =
                        Repo.all(
                          from(
                            s in School.Affairs.ExamAttendance,
                            where:
                              s.semester_id == ^item.semester and
                                s.institution_id == ^conn.private.plug_session["institution_id"] and
                                s.exam_master_id == ^item.exam_master_id and
                                s.class_id == ^class.id,
                            select: %{student_id: s.student_id}
                          )
                        )
                        |> Enum.uniq()

                      total_absent = absent |> Enum.count()

                      student_class = student_class |> Enum.count()

                      total = student_class - total_absent

                      total |> Integer.to_string()
                    end

                  rank = no + 1
                  rank = rank |> Integer.to_string()

                  %{
                    student_id: item.student_id,
                    student_name: item.student_name,
                    chinese_name: item.chinese_name,
                    class_name: item.class_name,
                    exam_master_id: item.exam_master_id,
                    exam_name: item.exam_name,
                    semester: item.semester,
                    semester_no: item.semester_no,
                    year: item.year,
                    subject_code: "CRank",
                    subject_name: "Class Rank",
                    subject_cname: "Class Rank",
                    rank: rank <> "/" <> total,
                    standard_id: item.standard_id
                  }
                else
                  []
                end
              end

            defit = end_fit |> Enum.filter(fn x -> x.student_id == stud_class.student_id end)

            desfit =
              if defit == [] do
                ""
              else
                a = defit |> hd

                a.rank
              end

            {no + 1, desfit}
          end

        finish_rank =
          if all != [] do
            all = all |> hd

            count = total_mark |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                  s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                    s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                    s3m = total_mark |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  else
                    IO.inspect("got more than 3 at line 894, class #{class_name}")
                    s1m = ""
                    s2m = ""
                    s3m = ""
                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "CRANK",
              description: "Class Rank",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_rank
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    standard_rank =
      for stud_class <- student_class do
        all =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                c.name == ^class_name and em.student_id == ^stud_class.student_id and
                  sc.semester_id == ^semester_id,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                semester_no: j.sem,
                year: j.year,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                grade: em.grade,
                standard_id: sc.level_id
              }
            )
          )

        all_result =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                e.level_id == ^class_info.level_id and sc.semester_id == ^semester_id and
                  sb.with_mark == 1,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                semester_no: j.sem,
                year: j.year,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                grade: em.grade,
                standard_id: sc.level_id
              }
            )
          )

        total_mark =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all_result |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            drg =
              if fit == [] do
                []
              else
                fit = fit |> Enum.group_by(fn x -> x.student_id end)

                data =
                  for items <- fit do
                    student_id = items |> elem(0)
                    items = items |> elem(1)

                    a =
                      case conn.private.plug_session["institution_id"] do
                        9 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          fail =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.filter(fn x ->
                              Decimal.to_float(x.mark) >= 1 and Decimal.to_float(x.mark) <= 39.9
                            end)

                          fail =
                            if fail != [] do
                              true
                            else
                              false
                            end

                          th =
                            if absent != [] do
                              true
                            else
                              false
                            end

                          if items != [] do
                            item = items |> hd

                            %{
                              student_id: item.student_id,
                              student_name: item.student_name,
                              chinese_name: item.chinese_name,
                              class_name: item.class_name,
                              exam_master_id: item.exam_master_id,
                              exam_name: item.exam_name,
                              semester: item.semester,
                              semester_no: item.semester_no,
                              year: item.year,
                              subject_code: "Standard",
                              subject_name: "Standard Rank",
                              subject_cname: "Standard Rank",
                              fail: fail,
                              th: th,
                              total_mark: sum,
                              standard_id: item.standard_id
                            }
                          end

                        10 ->
                          coming = items |> hd

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^coming.student_id and
                                    s.semester_id == ^coming.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^coming.exam_master_id
                              )
                            )

                          a =
                            if absent == [] do
                              sum =
                                items
                                |> Enum.filter(fn x -> x.mark != nil end)
                                |> Enum.filter(fn x -> x.mark != 0 end)
                                |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                                |> Enum.sum()

                              if items != [] do
                                item = items |> hd

                                %{
                                  student_id: item.student_id,
                                  student_name: item.student_name,
                                  chinese_name: item.chinese_name,
                                  class_name: item.class_name,
                                  exam_master_id: item.exam_master_id,
                                  exam_name: item.exam_name,
                                  semester: item.semester,
                                  semester_no: item.semester_no,
                                  year: item.year,
                                  subject_code: "Standard",
                                  subject_name: "Standard Rank",
                                  subject_cname: "Standard Rank",
                                  t_grade: "",
                                  total_mark: sum,
                                  standard_id: item.standard_id
                                }
                              end
                            else
                            end

                        3 ->
                          coming = items |> hd

                          # absent =
                          #   Repo.get_by(
                          #     School.Affairs.ExamAttendance,
                          #     student_id: coming.student_id,
                          #     semester_id: coming.semester,
                          #     institution_id: conn.private.plug_session["institution_id"],
                          #     exam_master_id: coming.exam_master_id
                          #   )

                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "Standard",
                                subject_name: "Standard Rank",
                                subject_cname: "Standard Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end

                        _ ->
                          sum =
                            items
                            |> Enum.filter(fn x -> x.mark != nil end)
                            |> Enum.filter(fn x -> x.mark != 0 end)
                            |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                            |> Enum.sum()

                          a =
                            if items != [] do
                              item = items |> hd

                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: "Standard",
                                subject_name: "Standard Rank",
                                subject_cname: "Standard Rank",
                                t_grade: "",
                                total_mark: sum,
                                standard_id: item.standard_id
                              }
                            end
                      end
                  end
                  |> Enum.filter(fn x -> x != nil end)

                data =
                  if conn.private.plug_session["institution_id"] == 9 do
                    data2 =
                      data
                      |> Enum.filter(fn x -> x.fail == true and x.th == false end)
                      |> Enum.uniq()
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    data3 =
                      data
                      |> Enum.filter(fn x -> x.th == true and x.fail == false end)
                      |> Enum.uniq()
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    data4 =
                      data
                      |> Enum.filter(fn x -> x.th == true and x.fail == true end)
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    all_p =
                      (data -- (data2 ++ data3 ++ data4))
                      |> Enum.uniq()
                      |> Enum.sort_by(fn x -> x.total_mark end)
                      |> Enum.reverse()

                    data = all_p ++ data2 ++ data3 ++ data4

                    data
                    |> School.assign_rank()
                    |> Enum.map(fn x -> {elem(x, 0), elem(x, 1) - 2} end)
                    |> Enum.drop(1)
                  else
                    data
                    |> Enum.sort_by(fn x -> x.total_mark end)
                    |> Enum.reverse()
                    |> Enum.with_index()
                  end

                data
              end

            end_fit =
              for item <- drg do
                if item != [] do
                  no = item |> elem(1)
                  item = item |> elem(0)

                  total =
                    case conn.private.plug_session["institution_id"] do
                      9 ->
                        absent =
                          Repo.all(
                            from(
                              s in School.Affairs.ExamAttendance,
                              left_join: k in School.Affairs.StudentClass,
                              on: s.student_id == k.sudent_id,
                              where:
                                k.level_id == ^class_info.level_id and
                                  s.semester_id == ^conn.private.plug_session["semester_id"] and
                                  k.institute_id == ^conn.private.plug_session["institution_id"] and
                                  s.exam_master_id == ^item.exam_master_id
                            )
                          )
                          |> Enum.uniq()
                          |> Enum.count()

                        total = all_student - absent

                      10 ->
                        absent =
                          Repo.all(
                            from(
                              s in School.Affairs.ExamAttendance,
                              left_join: k in School.Affairs.StudentClass,
                              on: s.student_id == k.sudent_id,
                              where:
                                k.level_id == ^class_info.level_id and
                                  s.semester_id == ^conn.private.plug_session["semester_id"] and
                                  k.institute_id == ^conn.private.plug_session["institution_id"] and
                                  s.exam_master_id == ^item.exam_master_id,
                              select: %{student_id: s.student_id}
                            )
                          )
                          |> Enum.uniq()
                          |> Enum.count()

                        IO.inspect("all_student#{all_student}")
                        IO.inspect("total_absent#{absent}")

                        total = all_student - absent

                      3 ->
                        total = all_student

                      _ ->
                        all_student =
                          Repo.all(
                            from(
                              sc in School.Affairs.StudentClass,
                              where:
                                sc.level_id == ^class_info.level_id and
                                  sc.semester_id == ^conn.private.plug_session["semester_id"] and
                                  sc.institute_id == ^conn.private.plug_session["institution_id"]
                            )
                          )
                          |> Enum.uniq()
                          |> Enum.count()

                        total = all_student
                    end

                  total =
                    if conn.private.plug_session["institution_id"] == 10 do
                      total |> Integer.to_string()
                    else
                      all_student |> Integer.to_string()
                    end

                  rank = no + 1
                  rank = rank |> Integer.to_string()

                  item = item

                  %{
                    student_id: item.student_id,
                    student_name: item.student_name,
                    chinese_name: item.chinese_name,
                    class_name: item.class_name,
                    exam_master_id: item.exam_master_id,
                    exam_name: item.exam_name,
                    semester: item.semester,
                    semester_no: item.semester_no,
                    year: item.year,
                    subject_code: "Standard",
                    subject_name: "Standard Rank",
                    subject_cname: "Standard Rank",
                    rank: rank <> "/" <> total,
                    standard_id: item.standard_id
                  }
                else
                  []
                end
              end

            defit = end_fit |> Enum.filter(fn x -> x.student_id == stud_class.student_id end)

            desfit =
              if defit == [] do
                ""
              else
                a = defit |> hd

                a.rank
              end

            {no + 1, desfit}
          end

        finish_rank =
          if all != [] do
            all = all |> hd

            count = total_mark |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                  s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                    s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                    s3m = total_mark |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "SRANK",
              description: "Standard Rank",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_rank
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    total_markfinish =
      for stud_class <- student_class do
        all =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                c.name == ^class_name and em.student_id == ^stud_class.student_id and
                  sc.semester_id == ^semester_id and sb.with_mark == 1,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                semester_no: j.sem,
                year: j.year,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                standard_id: sc.level_id
              }
            )
          )

        total_mark =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            fit =
              if fit == [] do
                ""
              else
                list =
                  case conn.private.plug_session["institution_id"] do
                    9 ->
                      list =
                        for item <- fit do
                          # subject =
                          #   Repo.get_by(
                          #     School.Affairs.Subject,
                          #     code: item.subject_code,
                          #     institution_id: conn.private.plug_session["institution_id"]
                          #   )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                left_join: sb in School.Affairs.Subject,
                                on: s.subject_id == sb.id,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id and sb.with_mark == 1
                              )
                            )

                          %{
                            student_id: item.student_id,
                            student_name: item.student_name,
                            chinese_name: item.chinese_name,
                            class_name: item.class_name,
                            exam_master_id: item.exam_master_id,
                            exam_name: item.exam_name,
                            semester: item.semester,
                            semester_no: item.semester_no,
                            year: item.year,
                            subject_code: item.subject_code,
                            subject_name: item.subject_name,
                            subject_cname: item.subject_cname,
                            mark: item.mark,
                            absent: absent |> Enum.count(),
                            standard_id: item.standard_id
                          }
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    10 ->
                      list =
                        for item <- fit do
                          subject =
                            Repo.get_by(
                              School.Affairs.Subject,
                              code: item.subject_code,
                              institution_id: conn.private.plug_session["institution_id"]
                            )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                left_join: sb in School.Affairs.Subject,
                                on: s.subject_id == sb.id,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id and
                                    s.subject_id == ^subject.id and sb.with_mark == 1
                              )
                            )

                          a =
                            if absent == [] do
                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: item.subject_code,
                                subject_name: item.subject_name,
                                subject_cname: item.subject_cname,
                                mark: item.mark,
                                standard_id: item.standard_id
                              }
                            end
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    3 ->
                      list = fit

                    _ ->
                      list = fit
                  end

                total_absent =
                  if conn.private.plug_session["institution_id"] == 9 do
                    a =
                      list
                      |> Enum.map(fn x -> x.absent end)
                      |> Enum.uniq()

                    if a == [] do
                      0
                    else
                      a |> hd
                    end
                  else
                    0
                  end

                a =
                  list
                  |> Enum.filter(fn x -> x.mark != 0 end)
                  |> Enum.filter(fn x -> x.mark != nil end)
                  |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                  |> Enum.sum()

                # per_th = list |> Enum.filter(fn x -> x.mark == nil end) |> Enum.count()

                per = list |> Enum.map(fn x -> x.subject_code end) |> Enum.uniq() |> Enum.count()
                IO.inspect("per, #{per}")

                IO.inspect("total_absent, #{total_absent}")

                per =
                  per =
                  if list |> Enum.any?(fn x -> x.subject_code == "AGM" end) do
                    per = per - 1 - total_absent
                    # per = per - 1 + per_th
                  else
                    per = per - total_absent
                    # per = per + per_th
                  end

                total_per = per * 100
                total_per = total_per |> Integer.to_string()

                a =
                  if a == 0.0 do
                    "0" <> "/" <> total_per
                  else
                    a = a |> Float.round(2) |> Float.to_string()

                    a <> "/" <> total_per
                  end
              end

            {no + 1, fit}
          end

        finish_total_mark =
          if all != [] do
            all = all |> hd

            count = total_mark |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                  s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_mark |> Enum.fetch!(0) |> elem(1)
                    s2m = total_mark |> Enum.fetch!(1) |> elem(1)
                    s3m = total_mark |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "TOTAL",
              description: "Total Mark Each Exam",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_total_mark
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    total_purata =
      for stud_class <- student_class do
        all =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                c.name == ^class_name and em.student_id == ^stud_class.student_id and
                  sc.semester_id == ^semester_id and sb.with_mark == 1,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                semester_no: j.sem,
                year: j.year,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                standard_id: sc.level_id
              }
            )
          )

        total_average =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all |> Enum.filter(fn x -> x.exam_master_id == exam.id end)

            fit =
              if fit == [] do
                ""
              else
                list =
                  case conn.private.plug_session["institution_id"] do
                    9 ->
                      list =
                        for item <- fit do
                          subject =
                            Repo.get_by(
                              School.Affairs.Subject,
                              code: item.subject_code,
                              institution_id: conn.private.plug_session["institution_id"]
                            )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id
                              )
                            )

                          %{
                            student_id: item.student_id,
                            student_name: item.student_name,
                            chinese_name: item.chinese_name,
                            class_name: item.class_name,
                            exam_master_id: item.exam_master_id,
                            exam_name: item.exam_name,
                            semester: item.semester,
                            semester_no: item.semester_no,
                            year: item.year,
                            subject_code: item.subject_code,
                            subject_name: item.subject_name,
                            subject_cname: item.subject_cname,
                            mark: item.mark,
                            absent: absent |> Enum.count(),
                            standard_id: item.standard_id
                          }
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    10 ->
                      list =
                        for item <- fit do
                          subject =
                            Repo.get_by(
                              School.Affairs.Subject,
                              code: item.subject_code,
                              institution_id: conn.private.plug_session["institution_id"]
                            )

                          absent =
                            Repo.all(
                              from(
                                s in School.Affairs.ExamAttendance,
                                where:
                                  s.student_id == ^item.student_id and
                                    s.semester_id == ^item.semester and
                                    s.institution_id ==
                                      ^conn.private.plug_session["institution_id"] and
                                    s.exam_master_id == ^item.exam_master_id
                              )
                            )

                          a =
                            if absent == [] do
                              %{
                                student_id: item.student_id,
                                student_name: item.student_name,
                                chinese_name: item.chinese_name,
                                class_name: item.class_name,
                                exam_master_id: item.exam_master_id,
                                exam_name: item.exam_name,
                                semester: item.semester,
                                semester_no: item.semester_no,
                                year: item.year,
                                subject_code: item.subject_code,
                                subject_name: item.subject_name,
                                subject_cname: item.subject_cname,
                                mark: item.mark,
                                absent: absent |> Enum.count(),
                                standard_id: item.standard_id
                              }
                            end
                        end
                        |> Enum.filter(fn x -> x != nil end)

                    3 ->
                      list = fit

                    _ ->
                      list = fit
                  end

                a =
                  list
                  |> Enum.filter(fn x -> x.mark != 0 end)
                  |> Enum.filter(fn x -> x.mark != nil end)
                  |> Enum.map(fn x -> Decimal.to_float(x.mark) end)
                  |> Enum.sum()

                total_absent =
                  if conn.private.plug_session["institution_id"] == 9 do
                    absent_data =
                      list
                      |> Enum.map(fn x -> x.absent end)
                      |> Enum.uniq()

                    if absent_data == [] do
                      0
                    else
                      absent_data |> hd
                    end
                  else
                    0
                  end

                per = list |> Enum.map(fn x -> x.subject_code end) |> Enum.uniq() |> Enum.count()

                per =
                  if list |> Enum.any?(fn x -> x.subject_code == "AGM" end) do
                    per = per - 1 - total_absent
                  else
                    per = per - total_absent
                  end

                total_per = per * 100

                total_average =
                  if total_per != 0 do
                    IO.puts("line 3920 #{a} / #{total_per}")
                    a / total_per * 100
                  else
                    0
                  end

                total_average =
                  if total_average != 0 do
                    total_average |> Float.round(2) |> Float.to_string()
                  else
                    0
                  end
              end

            {no + 1, fit}
          end

        finish_total_mark =
          if all != [] do
            all = all |> hd

            count = total_average |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_average |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_average |> Enum.fetch!(0) |> elem(1)
                  s2m = total_average |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_average |> Enum.fetch!(0) |> elem(1)
                    s2m = total_average |> Enum.fetch!(1) |> elem(1)
                    s3m = total_average |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "AVERG",
              description: "Total Average Each Exam",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        finish_total_mark
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    total_h_w =
      for stud_class <- student_class do
        all =
          Repo.all(
            from(
              em in School.Affairs.ExamMark,
              left_join: z in School.Affairs.Exam,
              on: em.exam_id == z.id,
              left_join: e in School.Affairs.ExamMaster,
              on: z.exam_master_id == e.id,
              left_join: j in School.Affairs.Semester,
              on: e.semester_id == j.id,
              left_join: s in School.Affairs.Student,
              on: em.student_id == s.id,
              left_join: sc in School.Affairs.StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in School.Affairs.Class,
              on: sc.class_id == c.id,
              left_join: sb in School.Affairs.Subject,
              on: em.subject_id == sb.id,
              where:
                c.name == ^class_name and em.student_id == ^stud_class.student_id and
                  sc.semester_id == ^semester_id,
              select: %{
                student_id: s.id,
                student_name: s.name,
                chinese_name: s.chinese_name,
                class_name: c.name,
                exam_master_id: e.id,
                exam_name: e.name,
                semester: j.id,
                semester_no: j.sem,
                year: j.year,
                subject_code: sb.code,
                subject_name: sb.description,
                subject_cname: sb.cdesc,
                mark: em.mark,
                standard_id: sc.level_id,
                student_heigt: s.height,
                student_weight: s.weight
              }
            )
          )

        total_hei_wei =
          for exam <- list_exam |> Enum.with_index() do
            no = exam |> elem(1)
            exam = exam |> elem(0)

            fit = all |> Enum.filter(fn x -> x.semester == exam.semester_id end)

            fit =
              if fit == [] do
                ""
              else
                a = fit |> hd

                student = Repo.get_by(School.Affairs.Student, id: a.student_id)

                data = student.height
                data2 = student.weight

                heig =
                  if data != nil do
                    data = data |> String.split(",")

                    hg =
                      for item <- data do
                        item = item |> String.split("-")

                        height = item |> Enum.fetch!(1)

                        semester = item |> Enum.fetch!(0)

                        {semester, height}
                      end

                    last =
                      hg
                      |> Enum.filter(fn x ->
                        x |> elem(0) == Integer.to_string(exam.semester_id)
                      end)
                      |> hd

                    last = last |> elem(1)
                  else
                    ""
                  end

                last_hg = heig

                weig =
                  if data2 != nil do
                    data2 = data2 |> String.split(",")

                    hg =
                      for item2 <- data2 do
                        item2 = item2 |> String.split("-")
                        weight = item2 |> Enum.fetch!(1)
                        semester = item2 |> Enum.fetch!(0)

                        {semester, weight}
                      end

                    last2 =
                      hg
                      |> Enum.filter(fn x ->
                        x |> elem(0) == Integer.to_string(exam.semester_id)
                      end)
                      |> hd

                    last2 = last2 |> elem(1)
                  else
                    ""
                  end

                last_wg = weig

                last_hg <> "CM" <> " , " <> last_wg <> "KG"
              end

            {no + 1, fit}
          end

        total_height_weight =
          if all != [] do
            all = all |> hd

            count = total_hei_wei |> Enum.count()

            {s1m, s2m, s3m} =
              if count == 1 do
                s1m = total_hei_wei |> Enum.fetch!(0) |> elem(1)
                s2m = ""
                s3m = ""

                {s1m, s2m, s3m}
              else
                if count == 2 do
                  s1m = total_hei_wei |> Enum.fetch!(0) |> elem(1)
                  s2m = total_hei_wei |> Enum.fetch!(1) |> elem(1)
                  s3m = ""

                  {s1m, s2m, s3m}
                else
                  if count == 3 do
                    s1m = total_hei_wei |> Enum.fetch!(0) |> elem(1)
                    s2m = total_hei_wei |> Enum.fetch!(1) |> elem(1)
                    s3m = total_hei_wei |> Enum.fetch!(2) |> elem(1)

                    {s1m, s2m, s3m}
                  end
                end
              end

            %{
              institution_id: conn.private.plug_session["institution_id"],
              stuid: all.student_id |> Integer.to_string(),
              name: all.student_name,
              cname: all.chinese_name,
              class: all.class_name,
              subject: "H&W",
              description: "Height and Weight",
              year: all.year |> Integer.to_string(),
              semester: all.semester_no |> Integer.to_string(),
              s1m: s1m,
              s2m: s2m,
              s3m: s3m,
              s1g: "",
              s2g: "",
              s3g: ""
            }
          end

        total_height_weight
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    result =
      result ++ class_rank ++ standard_rank ++ total_markfinish ++ total_purata ++ total_h_w

    exist =
      Repo.all(
        from(
          s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem)
        )
      )

    if exist != [] do
      Repo.delete_all(
        from(
          s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem)
        )
      )

      for item <- result do
        Affairs.create_mark_sheet_temp(item)
      end

      conn
      |> put_flash(:info, "Mark sheet temp created successfully.")
      |> redirect(to: "/report_card_generator")
    else
      for item <- result do
        Affairs.create_mark_sheet_temp(item)
      end

      conn
      |> put_flash(:info, "Mark sheet temp created successfully.")
      |> redirect(to: "/report_card_generator")
    end
  end

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

          2 ->
            "report_cards_test.html"

          _ ->
            "report_cards_kk.html"
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
        if id == 3 do
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

  def head_count_listing(conn, params) do
    class_id = params["class_id"]
    subject_id = params["subject_id"]
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    semester = Repo.get(Semester, conn.private.plug_session["semester_id"])

    semester_year = semester.year

    subject_info = Repo.get_by(School.Affairs.Subject, id: subject_id)
    class_info = Repo.get_by(School.Affairs.Class, id: class_id)

    teacher =
      Repo.all(
        from(
          q in School.Affairs.Timetable,
          left_join: m in School.Affairs.Period,
          on: m.timetable_id == q.id,
          left_join: g in School.Affairs.Subject,
          on: m.subject_id == g.id,
          left_join: h in School.Affairs.Teacher,
          on: q.teacher_id == h.id,
          where:
            g.timetable_code == ^subject_info.timetable_code and m.class_id == ^class_id and
              q.institution_id == ^conn.private.plug_session["institution_id"] and
              q.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            teacher: h.name,
            cteacher: h.cname
          }
        )
      )

    teacher =
      if teacher != [] do
        teacher |> hd
      else
        []
      end

    student_class =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: p in School.Affairs.Student,
          on: s.sudent_id == p.id,
          where:
            s.class_id == ^class_id and
              s.institute_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            student_name: p.name,
            chinese_name: p.chinese_name,
            sex: p.sex,
            class_id: s.class_id,
            student_id: s.sudent_id,
            student_no: p.student_no
          },
          order_by: [desc: p.sex, asc: p.name]
        )
      )

    etr =
      Repo.all(
        from(
          s in School.Affairs.HeadCount,
          left_join: p in School.Affairs.Student,
          on: s.student_id == p.id,
          where:
            s.class_id == ^class_id and s.subject_id == ^subject_id and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            student_name: p.name,
            chinese_name: p.chinese_name,
            sex: p.sex,
            class_id: s.class_id,
            subject_id: s.subject_id,
            student_id: s.student_id,
            mark: s.targer_mark
          }
        )
      )

    exam_name =
      Repo.all(
        from(
          p in School.Affairs.Exam,
          left_join: m in School.Affairs.ExamMaster,
          on: m.id == p.exam_master_id,
          where:
            m.semester_id == ^conn.private.plug_session["semester_id"] and
              m.institution_id == ^conn.private.plug_session["institution_id"] and
              p.subject_id == ^subject_id and m.level_id == ^class_info.level_id,
          select: %{
            exam: m.name
          }
        )
      )

    exam =
      Repo.all(
        from(
          p in School.Affairs.Exam,
          left_join: m in School.Affairs.ExamMaster,
          on: m.id == p.exam_master_id,
          left_join: h in School.Affairs.ExamMark,
          on: h.exam_id == p.id,
          where:
            m.semester_id == ^conn.private.plug_session["semester_id"] and
              m.institution_id == ^conn.private.plug_session["institution_id"] and
              h.subject_id == ^subject_id and h.class_id == ^class_id,
          select: %{
            student_id: h.student_id,
            mark: h.mark,
            class_id: h.class_id,
            exam: m.name
          }
        )
      )

    year = semester_year - 1

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "head_count_listing.html",
        class: class_info,
        subject: subject_info,
        student_class: student_class,
        exam: exam,
        etr: etr,
        school: school,
        semester_year: year |> Integer.to_string(),
        exam_name: exam_name,
        semester: semester,
        teacher: teacher
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

    # end
  end

  def head_count_listing_excel(conn, params) do
    class_id = params["class_id"]
    subject_id = params["subject_id"]
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    semester = Repo.get(Semester, conn.private.plug_session["semester_id"])

    semester_year = semester.year

    subject_info = Repo.get_by(School.Affairs.Subject, id: subject_id)
    class_info = Repo.get_by(School.Affairs.Class, id: class_id)

    teacher =
      Repo.all(
        from(
          q in School.Affairs.Timetable,
          left_join: m in School.Affairs.Period,
          on: m.timetable_id == q.id,
          left_join: g in School.Affairs.Subject,
          on: m.subject_id == g.id,
          left_join: h in School.Affairs.Teacher,
          on: q.teacher_id == h.id,
          where:
            g.timetable_code == ^subject_info.timetable_code and m.class_id == ^class_id and
              q.institution_id == ^conn.private.plug_session["institution_id"] and
              q.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            teacher: h.name,
            cteacher: h.cname
          }
        )
      )

    teacher =
      if teacher != [] do
        teacher |> hd
      else
        []
      end

    student_class =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: p in School.Affairs.Student,
          on: s.sudent_id == p.id,
          where:
            s.class_id == ^class_id and
              s.institute_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            student_name: p.name,
            chinese_name: p.chinese_name,
            sex: p.sex,
            class_id: s.class_id,
            student_id: s.sudent_id,
            student_no: p.student_no
          },
          order_by: [desc: p.sex, asc: p.name]
        )
      )

    etr =
      Repo.all(
        from(
          s in School.Affairs.HeadCount,
          left_join: p in School.Affairs.Student,
          on: s.student_id == p.id,
          where:
            s.class_id == ^class_id and s.subject_id == ^subject_id and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              s.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            student_name: p.name,
            chinese_name: p.chinese_name,
            sex: p.sex,
            class_id: s.class_id,
            subject_id: s.subject_id,
            student_id: s.student_id,
            mark: s.targer_mark
          }
        )
      )

    exam_name =
      Repo.all(
        from(
          p in School.Affairs.Exam,
          left_join: m in School.Affairs.ExamMaster,
          on: m.id == p.exam_master_id,
          where:
            m.semester_id == ^conn.private.plug_session["semester_id"] and
              m.institution_id == ^conn.private.plug_session["institution_id"] and
              p.subject_id == ^subject_id and m.level_id == ^class_info.level_id,
          select: %{
            exam: m.name
          }
        )
      )

    exam =
      Repo.all(
        from(
          p in School.Affairs.Exam,
          left_join: m in School.Affairs.ExamMaster,
          on: m.id == p.exam_master_id,
          left_join: h in School.Affairs.ExamMark,
          on: h.exam_id == p.id,
          where:
            m.semester_id == ^conn.private.plug_session["semester_id"] and
              m.institution_id == ^conn.private.plug_session["institution_id"] and
              h.subject_id == ^subject_id and h.class_id == ^class_id,
          select: %{
            student_id: h.student_id,
            mark: h.mark,
            class_id: h.class_id,
            exam: m.name
          }
        )
      )

    year = semester_year - 1

    # all =
    #   for item <- all |> Enum.with_index() do
    #     no = item |> elem(1)
    #     item = item |> elem(0)

    #     [
    #       {:no, (no + 1) |> Integer.to_string()},
    #       {:name, item.name},
    #       {:chinese_name, item.chinese_name},
    #       {:sex, item.sex}
    #     ]
    #   end
    exam_n = exam_name |> Enum.map(fn x -> x.exam end)

    csv_content1 = ["No", "Name", "Jan", "TOV"]
    csv_content2 = ["ETR"]
    csv_content = csv_content1 ++ exam_n ++ csv_content2

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

    student_class =
      for item <- student_class |> Enum.with_index() do
        no = item |> elem(1)

        item = item |> elem(0)

        sex =
          if item.sex == "M" or item.sex == "L" or item.sex == "MALE" or item.sex == "LELAKI" do
            "L"
          else
            if item.sex == "F" or item.sex == "P" or item.sex == "FEMALE" or
                 item.sex == "PEREMPUAN" do
              "P"
            end
          end

        # mark =
        #   for items <- exam_name do
        #     mark =
        #       exam
        #       |> Enum.filter(fn x -> x.exam == items.exam and x.student_id == item.student_id end)
        #   end

        # IEx.pry()
        %{a: no + 1, b: item.student_name <> "    " <> item.chinese_name, c: sex}
      end

    data =
      for item <- student_class |> Enum.with_index() do
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

    sheet = Sheet.with_name("HeadCount")

    total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

    total = total |> Sheet.set_col_width("B", 35.0) |> Sheet.set_col_width("C", 20.0)

    page = %Workbook{sheets: [total]}

    image_path = Application.app_dir(:school, "priv/static/images")

    content = page |> Elixlsx.write_to(image_path <> "/HeadCount.xlsx")

    file = File.read!(image_path <> "/HeadCount.xlsx")

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"HeadCount-#{class_info.name}.xlsx\""
    )
    |> send_resp(200, file)

    # html =
    #   Phoenix.View.render_to_string(
    #     SchoolWeb.PdfView,
    #     "head_count_listing.html",
    #     class: class_info,
    #     subject: subject_info,
    #     student_class: student_class,
    #     exam: exam,
    #     etr: etr,
    #     school: school,
    #     semester_year: year |> Integer.to_string(),
    #     exam_name: exam_name,
    #     semester: semester,
    #     teacher: teacher
    #   )

    # pdf_params = %{"html" => html}

    # pdf_binary =
    #   PdfGenerator.generate_binary!(
    #     pdf_params["html"],
    #     size: "A4",
    #     shell_params: [
    #       "--margin-left",
    #       "5",
    #       "--margin-right",
    #       "5",
    #       "--margin-top",
    #       "5",
    #       "--margin-bottom",
    #       "5",
    #       "--encoding",
    #       "utf-8"
    #     ],
    #     delete_temporary: true
    #   )

    # conn
    # |> put_resp_header("Content-Type", "application/pdf")
    # |> resp(200, pdf_binary)

    # end
  end

  def sheet_cell_insert(sheet, item) do
    sheet = sheet |> Sheet.set_cell(item |> elem(0), item |> elem(1))

    sheet
  end

  def user_login_report(conn, params) do
    users =
      Repo.all(
        from(
          s in User,
          left_join: g in Settings.UserAccess,
          on: s.id == g.user_id,
          left_join: k in Affairs.Teacher,
          on: s.email == k.email,
          where:
            g.institution_id == ^conn.private.plug_session["institution_id"] and k.is_delete != 1
        )
      )
      |> Enum.group_by(fn x -> x.role end)

    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "user_login_report.html",
        users: users,
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

  def print_timetable(conn, params) do
    IEx.pry()
  end

  def report_card_personal_summary(conn, params) do
    semester =
      Repo.get_by(
        Semester,
        id: params["semester"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    start_month = Timex.beginning_of_month(semester.year, params["month"] |> String.to_integer())

    end_month = Timex.end_of_month(semester.year, params["month"] |> String.to_integer())

    lists = Date.range(start_month, end_month) |> Enum.map(fn x -> x end)

    teachers =
      Repo.all(
        from(
          t in Teacher,
          where:
            t.institution_id == ^conn.private.plug_session["institution_id"] and t.is_delete != 1
        )
      )

    all =
      for teacher <- teachers do
        for list <- lists do
          all =
            Repo.all(
              from(
                g in School.Affairs.TeacherAttendance,
                left_join: k in School.Affairs.Teacher,
                on: k.id == g.teacher_id,
                where:
                  g.semester_id == ^params["semester"] and
                    k.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.month == ^params["month"] and k.id == ^teacher.id,
                select: %{
                  name: k.name,
                  cname: k.cname,
                  code: k.code,
                  icno: k.icno,
                  teacher_id: k.id,
                  time_in: g.time_in,
                  time_out: g.time_out,
                  date: g.date,
                  month: g.month,
                  remark: g.remark,
                  alasan: g.alasan
                }
              )
            )

          new =
            for item <- all do
              no1 = item.date |> String.split("-") |> Enum.fetch!(0)
              no2 = item.date |> String.split("-") |> Enum.fetch!(1)
              no3 = item.date |> String.split("-") |> Enum.fetch!(2)

              no1 =
                if no1 |> String.to_integer() <= 9 do
                  "0" <> no1
                else
                  no1
                end

              no2 =
                if no2 |> String.to_integer() <= 9 do
                  "0" <> no2
                else
                  no2
                end

              no3 =
                if no3 |> String.to_integer() <= 9 do
                  "0" <> no3
                else
                  no3
                end

              new_date = no3 <> "-" <> no2 <> "-" <> no1

              new_date = new_date |> Date.from_iso8601!()

              new_time_in =
                if item.time_in != nil do
                  time_in =
                    item.time_in |> String.split(" ") |> Enum.fetch!(1) |> String.split(":")

                  ti1 = time_in |> Enum.fetch!(0)
                  ti2 = time_in |> Enum.fetch!(1)
                  ti3 = time_in |> Enum.fetch!(2)

                  ti1 =
                    if ti1 |> String.to_integer() <= 9 do
                      "0" <> ti1
                    else
                      ti1
                    end

                  ti2 =
                    if ti2 |> String.to_integer() <= 9 do
                      "0" <> ti2
                    else
                      ti2
                    end

                  ti3 =
                    if ti3 |> String.to_integer() <= 9 do
                      "0" <> ti3
                    else
                      ti3
                    end

                  new_time_in = ti1 <> ":" <> ti2 <> ":" <> ti3
                else
                  new_time_in = ""
                end

              new_time_out =
                if item.time_out != nil do
                  time_out =
                    item.time_out |> String.split(" ") |> Enum.fetch!(1) |> String.split(":")

                  to1 = time_out |> Enum.fetch!(0)
                  to2 = time_out |> Enum.fetch!(1)
                  to3 = time_out |> Enum.fetch!(2)

                  to1 =
                    if to1 |> String.to_integer() <= 9 do
                      "0" <> to1
                    else
                      to1
                    end

                  to2 =
                    if to2 |> String.to_integer() <= 9 do
                      "0" <> to2
                    else
                      to2
                    end

                  to3 =
                    if to3 |> String.to_integer() <= 9 do
                      "0" <> to3
                    else
                      to3
                    end

                  new_time_out = to1 <> ":" <> to2 <> ":" <> to3
                else
                  new_time_out = ""
                end

              %{
                name: item.name,
                cname: item.cname,
                code: item.code,
                icno: item.icno,
                teacher_id: item.teacher_id,
                time_in: new_time_in,
                time_out: new_time_out,
                date: new_date,
                month: item.month,
                remark: item.remark,
                alasan: item.alasan
              }
            end
            |> Enum.filter(fn x -> x.date == list end)

          all2 =
            Repo.all(
              from(
                g in School.Affairs.TeacherAbsent,
                left_join: k in School.Affairs.Teacher,
                on: k.id == g.teacher_id,
                where:
                  g.semester_id == ^params["semester"] and
                    k.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.month == ^params["month"] and k.id == ^teacher.id,
                select: %{
                  name: k.name,
                  cname: k.cname,
                  code: k.code,
                  icno: k.icno,
                  teacher_id: k.id,
                  time_in: "",
                  time_out: "",
                  date: g.date,
                  month: g.month,
                  remark: g.remark,
                  alasan: g.alasan
                }
              )
            )
            |> Enum.filter(fn x -> x.date == list end)

          new = new ++ all2

          if new != [] do
            new = new |> hd

            new
          else
            %{
              name: teacher.name,
              cname: teacher.cname,
              code: teacher.code,
              teacher_id: teacher.id,
              icno: teacher.icno,
              time_in: "",
              time_out: "",
              date: list,
              month: "",
              remark: "",
              alasan: ""
            }
          end
        end
      end
      |> List.flatten()
      |> Enum.group_by(fn x -> x.teacher_id end)

    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "personal_attendence_summary.html",
        all: all,
        school: school,
        start_month: start_month,
        end_month: end_month
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

  def report_card_summary(conn, params) do
    semester =
      Repo.get_by(
        Semester,
        id: params["semester"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    start_month = Timex.beginning_of_month(semester.year, params["month"] |> String.to_integer())

    end_month = Timex.end_of_month(semester.year, params["month"] |> String.to_integer())

    lists = Date.range(start_month, end_month) |> Enum.map(fn x -> x end)

    teachers =
      Repo.all(
        from(
          t in Teacher,
          where:
            t.institution_id == ^conn.private.plug_session["institution_id"] and t.is_delete != 1
        )
      )

    all =
      for teacher <- teachers do
        all =
          Repo.all(
            from(
              g in School.Affairs.TeacherAttendance,
              left_join: k in School.Affairs.Teacher,
              on: k.id == g.teacher_id,
              where:
                g.semester_id == ^params["semester"] and
                  k.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.month == ^params["month"] and k.id == ^teacher.id,
              select: %{
                name: k.name,
                cname: k.cname,
                teacher_id: k.id,
                remark: g.remark,
                alasan: g.alasan
              }
            )
          )

        all2 =
          Repo.all(
            from(
              g in School.Affairs.TeacherAbsent,
              left_join: k in School.Affairs.Teacher,
              on: k.id == g.teacher_id,
              where:
                g.institution_id == ^conn.private.plug_session["institution_id"] and
                  g.teacher_id == ^teacher.id and g.month == ^params["month"],
              select: %{
                name: k.name,
                cname: k.cname,
                teacher_id: k.id,
                remark: g.remark,
                alasan: g.alasan
              }
            )
          )

        all = all ++ all2

        submit =
          if all != [] do
            hadir = all |> Enum.filter(fn x -> x.remark == "HADIR" end) |> Enum.count()
            lewat = all |> Enum.filter(fn x -> x.remark == "LEWAT" end) |> Enum.count()
            balik_awl = all |> Enum.filter(fn x -> x.remark == "BALIK AWAL" end) |> Enum.count()

            cuti_dengan_alasan =
              all
              |> Enum.filter(fn x -> x.remark == "CUTI DENGAN ALASAN" end)
              |> Enum.map(fn x -> x.alasan end)

            rem =
              for item <- cuti_dengan_alasan do
                calc = all |> Enum.filter(fn x -> x.alasan == item end) |> Enum.count()

                {item <> "=" <> (calc |> Integer.to_string()), calc}
              end
              |> Enum.filter(fn x -> x |> elem(1) != 0 end)

            tidak_hadir_dengan_alasan = cuti_dengan_alasan |> Enum.count()

            jumlah2 = rem |> Enum.count()

            alasan = rem |> Enum.map(fn x -> x |> elem(0) end)

            alasan =
              if alasan != [] do
                alasan = alasan |> hd
              else
                ""
              end

            total = hadir + lewat + balik_awl

            profile = all |> hd

            %{
              name: profile.name,
              cname: profile.cname,
              hadir: hadir,
              lewat: lewat,
              balik_awl: balik_awl,
              total: total,
              sakit: "",
              tidak_hadir_dengan_alasan: tidak_hadir_dengan_alasan,
              tidak_hadir_tampa_alasan: "",
              jumlah2: jumlah2,
              alasan: alasan
            }
          else
            %{
              name: teacher.name,
              cname: teacher.cname,
              hadir: "",
              lewat: "",
              balik_awl: "",
              total: 0,
              sakit: "",
              tidak_hadir_dengan_alasan: "",
              tidak_hadir_tampa_alasan: "",
              jumlah2: 0,
              alasan: ""
            }
          end

        submit
      end

    total_attende =
      Repo.all(
        from(
          g in School.Affairs.TeacherAttendance,
          left_join: k in School.Affairs.Teacher,
          on: k.id == g.teacher_id,
          where:
            g.semester_id == ^params["semester"] and
              k.institution_id == ^conn.private.plug_session["institution_id"] and
              g.institution_id == ^conn.private.plug_session["institution_id"] and
              g.month == ^params["month"],
          select: %{
            name: k.name,
            cname: k.cname,
            teacher_id: k.id,
            remark: g.remark,
            alasan: g.alasan
          }
        )
      )
      |> Enum.count()

    total_absent =
      Repo.all(
        from(
          g in School.Affairs.TeacherAbsent,
          left_join: k in School.Affairs.Teacher,
          on: k.id == g.teacher_id,
          where:
            g.institution_id == ^conn.private.plug_session["institution_id"] and
              g.month == ^params["month"],
          select: %{
            name: k.name,
            cname: k.cname,
            teacher_id: k.id,
            remark: g.remark,
            alasan: g.alasan
          }
        )
      )
      |> Enum.count()

    percentage = (total_attende / (total_attende + total_absent) * 100) |> Float.round(2)

    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "report_card_summary.html",
        all: all,
        school: school,
        start_month: start_month,
        end_month: end_month,
        percentage: percentage
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

  def parent_listing(conn, params) do
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    class_id = params["class"] |> String.to_integer()

    semester =
      Repo.get_by(School.Affairs.Semester, %{
        id: params["semester_id"],
        institution_id: conn.private.plug_session["institution_id"]
      })

    q =
      from(
        p in Parent,
        left_join: s in Student,
        on: s.gicno == p.icno,
        left_join: sc in StudentClass,
        on: sc.sudent_id == s.id,
        left_join: c in Class,
        on: c.id == sc.class_id,
        where:
          sc.semester_id == ^semester.id and
            p.institution_id == ^conn.private.plug_session["institution_id"] and
            s.institution_id == ^conn.private.plug_session["institution_id"] and
            c.institution_id == ^conn.private.plug_session["institution_id"],
        select: %{
          parent: p.name,
          cparent: p.cname,
          icno: p.icno,
          child: s.name,
          cchild: s.chinese_name,
          student_no: s.student_no,
          class: c.name,
          sex: s.sex
        },
        order_by: [p.icno]
      )

    data1 = Repo.all(q)

    q =
      from(
        p in Parent,
        left_join: s in Student,
        on: s.ficno == p.icno,
        left_join: sc in StudentClass,
        on: sc.sudent_id == s.id,
        left_join: c in Class,
        on: c.id == sc.class_id,
        where:
          sc.semester_id == ^semester.id and
            p.institution_id == ^conn.private.plug_session["institution_id"] and
            s.institution_id == ^conn.private.plug_session["institution_id"] and
            c.institution_id == ^conn.private.plug_session["institution_id"],
        select: %{
          parent: p.name,
          cparent: p.cname,
          icno: p.icno,
          child: s.name,
          cchild: s.chinese_name,
          student_no: s.student_no,
          class: c.name,
          sex: s.sex
        },
        order_by: [p.icno]
      )

    data2 = Repo.all(q)

    q =
      from(
        p in Parent,
        left_join: s in Student,
        on: s.micno == p.icno,
        left_join: sc in StudentClass,
        on: sc.sudent_id == s.id,
        left_join: c in Class,
        on: c.id == sc.class_id,
        where:
          sc.semester_id == ^semester.id and
            p.institution_id == ^conn.private.plug_session["institution_id"] and
            s.institution_id == ^conn.private.plug_session["institution_id"] and
            c.institution_id == ^conn.private.plug_session["institution_id"],
        select: %{
          parent: p.name,
          cparent: p.cname,
          icno: p.icno,
          child: s.name,
          cchild: s.chinese_name,
          student_no: s.student_no,
          class: c.name,
          sex: s.sex
        },
        order_by: [p.icno]
      )

    data3 = Repo.all(q)
    data = (data1 ++ data2 ++ data3) |> Enum.uniq()

    data =
      if class_id != 0 do
        class =
          Repo.get_by(School.Affairs.Class, %{
            id: class_id,
            institution_id: conn.private.plug_session["institution_id"]
          })

        data |> Enum.filter(fn x -> x.class == class.name end)
      else
        data
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "parent_listing.html",
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
  end

  def display_student_certificate(conn, params) do
    school = Repo.get(Institution, User.institution_id(conn))
    semester = Repo.get(Semester, params["semester_id"])
    class = Repo.get(Class, params["class_id"])

    students =
      Repo.all(
        from(
          s in Student,
          left_join: c in StudentClass,
          on: c.sudent_id == s.id,
          where:
            c.class_id == ^params["class_id"] and c.semester_id == ^semester.id and
              s.institution_id == ^conn.private.plug_session["institution_id"],
          order_by: [asc: s.name],
          select: %{
            id: s.id,
            ic: s.ic,
            name: s.name,
            b_cert: s.b_cert
          }
        )
      )

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "student_cert.html",
        students: students,
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

  def height_weight_report_show(conn, params) do
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    semester =
      Repo.get_by(School.Affairs.Semester, %{
        id: params["semester_id"],
        institution_id: conn.private.plug_session["institution_id"]
      })

    students =
      if params["class_id"] != "all_class" do
        class = Repo.get(Class, params["class_id"])

        Repo.all(
          from(
            s in Student,
            left_join: c in StudentClass,
            on: c.sudent_id == s.id,
            where:
              c.class_id == ^params["class_id"] and c.semester_id == ^semester.id and
                s.institution_id == ^conn.private.plug_session["institution_id"],
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
        Repo.all(
          from(
            s in Student,
            left_join: c in StudentClass,
            on: c.sudent_id == s.id,
            left_join: cl in Class,
            on: cl.id == c.class_id,
            where:
              c.semester_id == ^semester.id and
                s.institution_id == ^conn.private.plug_session["institution_id"] and
                c.institute_id == ^conn.private.plug_session["institution_id"],
            order_by: [cl.name, s.name],
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
        {class, student} =
          if params["class_id"] != "all_class" do
            class = Repo.get(Class, params["class_id"])
            student = Map.put(student, :class, class.name)
            {class, student}
          else
            student_class =
              Repo.get_by(StudentClass, sudent_id: student.id, semester_id: semester.id)

            class = Repo.get(Class, student_class.class_id)
            student = Map.put(student, :class, class.name)

            {class, student}
          end

        height_final =
          if student.height != nil do
            heights = String.split(student.height, ",")

            height_d =
              for height <- heights do
                semester_id =
                  String.split(height, "-") |> List.to_tuple() |> elem(0) |> String.to_integer()

                if semester_id == semester.id do
                  height
                else
                  nil
                end
              end

            height =
              height_d
              |> Enum.reject(fn x -> x == nil end)
              |> List.to_string()
              |> String.split("-")

            if Enum.count(height) > 1 do
              height
              |> List.to_tuple()
              |> elem(1)
            else
              nil
            end
          end

        weight =
          if student.weight != nil do
            weights = String.split(student.weight, ",")

            weight_d =
              for weight <- weights do
                semester_id =
                  String.split(weight, "-") |> List.to_tuple() |> elem(0) |> String.to_integer()

                if semester_id == semester.id do
                  weight
                else
                  nil
                end
              end

            weight =
              weight_d
              |> Enum.reject(fn x -> x == nil end)
              |> List.to_string()
              |> String.split("-")

            weight =
              if Enum.count(weight) > 1 do
                weight
                |> List.to_tuple()
                |> elem(1)
              else
                nil
              end
          end

        student = Map.put(student, :height, height_final)

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

  def mark_sheet_listing(conn, params) do
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    class_name = params["class"]
    exam_mid = params["exam"] |> String.to_integer()

    q =
      from(
        e in ExamMark,
        left_join: s in Student,
        on: s.id == e.student_id,
        left_join: ss in Subject,
        on: ss.id == e.subject_id,
        left_join: c in Class,
        on: c.id == e.class_id,
        left_join: em in ExamMaster,
        on: e.exam_id == em.id,
        where:
          em.id == ^exam_mid and c.name == ^class_name and
            s.institution_id == ^conn.private.plug_session["institution_id"] and
            ss.institution_id == ^conn.private.plug_session["institution_id"] and
            c.institution_id == ^conn.private.plug_session["institution_id"] and
            em.institution_id == ^conn.private.plug_session["institution_id"],
        select: %{
          gender: s.sex,
          student: s.name,
          c_student: s.chinese_name,
          class: c.name,
          year: em.year,
          exam: em.name,
          exam_mid: em.id,
          subject: ss.description,
          mark: e.mark
        },
        order_by: [c.name, ss.description, s.name]
      )

    data = Repo.all(q)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "mark_sheet_listing.html",
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

  def exam_result_standard(conn, params) do
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

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
        where:
          e.class_id == ^params["class"] and em.semester_id == ^params["semester"] and
            s.institution_id == ^conn.private.plug_session["institution_id"] and
            ss.institution_id == ^conn.private.plug_session["institution_id"] and
            c.institution_id == ^conn.private.plug_session["institution_id"] and
            em.institution_id == ^conn.private.plug_session["institution_id"],
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
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])

    semester_start = params["semester"] |> String.split(" - ") |> hd()
    semester_end = params["semester"] |> String.split(" - ") |> tl() |> hd()

    semester =
      Repo.get_by(
        Semester,
        start_date: Date.from_iso8601!(semester_start),
        end_date: Date.from_iso8601!(semester_end),
        institution_id: conn.private.plug_session["institution_id"]
      )

    q =
      from(
        ss in StandardSubject,
        left_join: l in Level,
        on: l.id == ss.standard_id,
        left_join: s in Subject,
        on: s.id == ss.subject_id,
        where:
          ss.institution_id == ^conn.private.plug_session["institution_id"] and
            l.institution_id == ^conn.private.plug_session["institution_id"] and
            s.institution_id == ^conn.private.plug_session["institution_id"],
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
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])
    class_name = params["class"]
    semester_start = params["semester"] |> String.split(" - ") |> hd()
    semester_end = params["semester"] |> String.split(" - ") |> tl() |> hd()

    semester =
      Repo.get_by(
        Semester,
        start_date: Date.from_iso8601!(semester_start),
        end_date: Date.from_iso8601!(semester_end),
        institution_id: conn.private.plug_session["institution_id"]
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
          where:
            c.institution_id == ^conn.private.plug_session["institution_id"] and
              l.institution_id == ^conn.private.plug_session["institution_id"] and
              t.institution_id == ^conn.private.plug_session["institution_id"] and
              j.institution_id == ^conn.private.plug_session["institution_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"],
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
    school = Repo.get(Institution, conn.private.plug_session["institution_id"])
    class_name = params["class"]
    semester_start = params["semester"] |> String.split(" - ") |> hd()
    semester_end = params["semester"] |> String.split(" - ") |> tl() |> hd()

    semester =
      Repo.get_by(
        Semester,
        start_date: Date.from_iso8601!(semester_start),
        end_date: Date.from_iso8601!(semester_end),
        institution_id: conn.private.plug_session["institution_id"]
      )

    data =
      if class_name == "ALL" do
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
            where:
              sc.institute_id == ^conn.private.plug_session["institution_id"] and
                s.institution_id == ^conn.private.plug_session["institution_id"] and
                c.institution_id == ^conn.private.plug_session["institution_id"] and
                l.institution_id == ^conn.private.plug_session["institution_id"] and
                sm.institution_id == ^conn.private.plug_session["institution_id"] and
                sc.semester_id == ^semester.id,
            group_by: [l.name, c.name, s.sex],
            select: %{
              class: c.name,
              gender: s.sex,
              gender_count: count(s.sex),
              level: l.name
            }
          )
        )
      else
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
            where:
              sc.institute_id == ^conn.private.plug_session["institution_id"] and
                s.institution_id == ^conn.private.plug_session["institution_id"] and
                c.institution_id == ^conn.private.plug_session["institution_id"] and
                l.institution_id == ^conn.private.plug_session["institution_id"] and
                sm.institution_id == ^conn.private.plug_session["institution_id"] and
                sc.semester_id == ^semester.id and c.name == ^class_name,
            group_by: [l.name, c.name, s.sex],
            select: %{
              class: c.name,
              gender: s.sex,
              gender_count: count(s.sex),
              level: l.name
            }
          )
        )
      end

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

  def class_ranking(conn, params) do
    class_id = params["class_id"] |> String.to_integer()
    exam_id = params["exam_id"] |> String.to_integer()

    class =
      Repo.get_by(
        School.Affairs.Class,
        id: params["class_id"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    exam =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: d in School.Affairs.Exam,
          on: d.id == e.exam_id,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == d.exam_master_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: sc in School.Affairs.StudentClass,
          on: sc.sudent_id == s.id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.class_id == ^class_id and k.id == ^exam_id and
              k.institution_id == ^conn.private.plug_session["institution_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              sc.semester_id == ^exam.semester_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            student_grade: e.grade,
            chinese_name: s.chinese_name,
            sex: s.sex,
            standard_id: k.level_id
          }
        )
      )

    standard_id =
      if exam_mark != [] do
        hd(exam_mark).standard_id
      end

    exam_standard =
      Repo.all(
        from(
          e in School.Affairs.Exam,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_master_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.exam_master_id == ^exam_id and
              k.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            subject_code: p.code,
            exam_name: k.name
          }
        )
      )

    all =
      for item <- exam_standard do
        exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd
        student_list = exam_mark |> Enum.map(fn x -> x.student_id end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student =
              Repo.get_by(School.Affairs.Student, %{
                id: item,
                institution_id: conn.private.plug_session["institution_id"]
              })

            s_mark = all_mark |> Enum.filter(fn x -> x.student_id == item end)

            a =
              if s_mark != [] do
                s_mark
              else
                %{
                  chinese_name: student.chinese_name,
                  sex: student.sex,
                  student_name: item,
                  student_id: student.id,
                  student_mark: nil,
                  student_grade: "E",
                  exam_name: exam_name,
                  subject_code: subject_code
                }
              end
          end
      end
      |> List.flatten()

    exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd

    all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        subject =
          Repo.get_by(
            School.Affairs.Subject,
            code: subject_code,
            institution_id: conn.private.plug_session["institution_id"]
          )

        if subject.with_mark != 1 do
          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            %{
              student_id: data.student_id,
              student_name: data.student_name,
              grade: data.student_grade,
              gpa: 0,
              subject_code: data.subject_code,
              student_mark: 0,
              chinese_name: data.chinese_name,
              sex: data.sex
            }
          end
        else
          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            total_grade =
              if student_mark != nil do
                grades =
                  Repo.all(
                    from(
                      g in School.Affairs.ExamGrade,
                      where:
                        g.institution_id == ^conn.private.plug_session["institution_id"] and
                          g.exam_master_id == ^exam_id
                    )
                  )

                for grade <- grades do
                  if Decimal.to_float(student_mark) >= Decimal.to_float(grade.min) and
                       Decimal.to_float(student_mark) <= Decimal.to_float(grade.max) do
                    %{
                      student_id: data.student_id,
                      student_name: data.student_name,
                      grade: grade.name,
                      gpa: grade.gpa,
                      subject_code: data.subject_code,
                      student_mark: Decimal.to_float(data.student_mark),
                      chinese_name: data.chinese_name,
                      sex: data.sex
                    }
                  end
                end
                |> Enum.filter(fn x -> x != nil end)
                |> hd
              else
                %{
                  student_id: data.student_id,
                  student_name: data.student_name,
                  grade: "E",
                  gpa: nil,
                  subject_code: subject_code,
                  student_mark: 0.0,
                  chinese_name: data.chinese_name,
                  sex: data.sex
                }
              end
          end
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    news = mark1 |> Enum.group_by(fn x -> x.student_id end)

    subject_all =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and s.with_mark == 1,
          select: s.code
        )
      )

    z =
      for new <- news do
        total =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.sum()
          |> Float.round(2)

        per =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.count()

        total_per = per * 100

        student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd

        chinese_name = new |> elem(1) |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd

        name = new |> elem(1) |> Enum.map(fn x -> x.student_name end) |> Enum.uniq() |> hd

        sex = new |> elem(1) |> Enum.map(fn x -> x.sex end) |> Enum.uniq() |> hd

        a = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        total_gpa =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.filter(fn x -> x.gpa != nil end)
          |> Enum.map(fn x -> Decimal.to_float(x.gpa) end)
          |> Enum.sum()

        cgpa =
          if total_gpa != 0 do
            (total_gpa / per) |> Float.round(2)
          else
            0
          end

        total_average =
          if total != 0 do
            (total / total_per * 100) |> Float.round(2)
          else
            0
          end

        %{
          subject: new |> elem(1) |> Enum.sort_by(fn x -> x.subject_code end),
          name: name,
          chinese_name: chinese_name,
          sex: sex,
          student_id: student_id,
          total_mark: total,
          per: per,
          total_per: total_per,
          total_average: total_average,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          f: f,
          g: g,
          cgpa: cgpa
        }
      end
      |> Enum.sort_by(fn x -> x.total_mark end)
      |> Enum.reverse()
      |> Enum.with_index()

    k =
      for item <- z do
        rank = item |> elem(1)
        item = item |> elem(0)

        %{
          subject: item.subject,
          name: item.name,
          chinese_name: item.chinese_name,
          sex: item.sex,
          student_id: item.student_id,
          total_mark: item.total_mark,
          per: item.per,
          total_per: item.total_per,
          total_average: item.total_average,
          a: item.a,
          b: item.b,
          c: item.c,
          d: item.d,
          e: item.e,
          f: item.f,
          g: item.g,
          cgpa: item.cgpa,
          rank: rank + 1
        }
      end
      |> Enum.sort_by(fn x -> x.name end)
      |> Enum.with_index()

    mark = mark1 |> Enum.group_by(fn x -> x.subject_code end)

    total_student = news |> Map.keys() |> Enum.count()

    institution =
      Repo.get_by(School.Settings.Institution, %{
        id: conn.private.plug_session["institution_id"]
      })

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "class_rank.html",
        z: k,
        class: class,
        exam_name: exam_name,
        mark: mark,
        mark1: mark1,
        total_student: total_student,
        class_id: params["class_id"],
        exam_id: params["exam_id"],
        institution: institution
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

  def standard_ranking(conn, params) do
    exam_id = params["exam_id"] |> String.to_integer()
    level_id = params["level_id"] |> String.to_integer()

    exam_id =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam_id,
        level_id: level_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    level =
      Repo.get_by(School.Affairs.Level, %{
        id: level_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: d in School.Affairs.Exam,
          on: d.id == e.exam_id,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == d.exam_master_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            d.exam_master_id == ^exam_id.id and k.level_id == ^level_id and
              k.institution_id == ^conn.private.plug_session["institution_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            student_grade: e.grade,
            class_id: e.class_id,
            chinese_name: s.chinese_name,
            sex: s.sex
          }
        )
      )

    exam_standard =
      Repo.all(
        from(
          e in School.Affairs.Exam,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_master_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.exam_master_id == ^exam_id.id and
              k.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            subject_code: p.code,
            exam_name: k.name
          }
        )
      )

    all =
      for item <- exam_standard do
        exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd
        student_list = exam_mark |> Enum.map(fn x -> x.student_id end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student =
              Repo.get_by(School.Affairs.Student, %{
                id: item,
                institution_id: conn.private.plug_session["institution_id"]
              })

            student_class =
              Repo.get_by(School.Affairs.StudentClass, %{
                sudent_id: student.id,
                semester_id: exam_id.semester_id
              })

            s_mark = all_mark |> Enum.filter(fn x -> x.student_id == item end)

            a =
              if s_mark != [] do
                s_mark
              else
                %{
                  chinese_name: student.chinese_name,
                  sex: student.sex,
                  student_name: student.name,
                  student_id: student.id,
                  student_mark: nil,
                  student_grade: "E",
                  exam_name: exam_name,
                  subject_code: subject_code,
                  class_id: student_class.class_id
                }
              end
          end
      end
      |> List.flatten()

    exam_name = all |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd

    all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        datas = item |> elem(1)

        subject =
          Repo.get_by(
            School.Affairs.Subject,
            code: subject_code,
            institution_id: conn.private.plug_session["institution_id"]
          )

        if subject.with_mark != 1 do
          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

            %{
              student_id: data.student_id,
              student_name: data.student_name,
              grade: data.student_grade,
              gpa: 0,
              subject_code: subject_code,
              student_mark: 0,
              class_id: data.class_id,
              chinese_name: data.chinese_name,
              sex: data.sex
            }
          end
        else
          for data <- datas do
            student_mark = data.student_mark

            total_grade =
              if student_mark != nil do
                grades =
                  Repo.all(
                    from(
                      g in School.Affairs.ExamGrade,
                      where:
                        g.institution_id == ^conn.private.plug_session["institution_id"] and
                          g.exam_master_id == ^exam_id.id
                    )
                  )

                total_grade =
                  for grade <- grades do
                    if Decimal.to_float(student_mark) >= Decimal.to_float(grade.min) and
                         Decimal.to_float(student_mark) <= Decimal.to_float(grade.max) do
                      %{
                        student_id: data.student_id,
                        student_name: data.student_name,
                        grade: grade.name,
                        gpa: grade.gpa,
                        subject_code: subject_code,
                        student_mark: Decimal.to_float(student_mark),
                        class_id: data.class_id,
                        chinese_name: data.chinese_name,
                        sex: data.sex
                      }
                    end
                  end
                  |> Enum.filter(fn x -> x != nil end)
                  |> hd
              else
                %{
                  student_id: data.student_id,
                  student_name: data.student_name,
                  grade: "E",
                  gpa: nil,
                  subject_code: subject_code,
                  student_mark: 0.0,
                  class_id: data.class_id,
                  chinese_name: data.chinese_name,
                  sex: data.sex
                }
              end
          end
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)

    news = mark1 |> Enum.group_by(fn x -> x.student_id end)

    subject_all =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and s.with_mark == 1,
          select: s.code
        )
      )

    z =
      for new <- news do
        total =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.sum()
          |> Float.round(2)

        per =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.count()

        total_per = per * 100

        class_id = new |> elem(1) |> Enum.map(fn x -> x.class_id end) |> Enum.uniq() |> hd
        student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd
        chinese_name = new |> elem(1) |> Enum.map(fn x -> x.chinese_name end) |> Enum.uniq() |> hd
        name = new |> elem(1) |> Enum.map(fn x -> x.student_name end) |> Enum.uniq() |> hd
        sex = new |> elem(1) |> Enum.map(fn x -> x.sex end) |> Enum.uniq() |> hd

        a = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = new |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        total_gpa =
          new
          |> elem(1)
          |> Enum.filter(fn x -> x.subject_code in subject_all end)
          |> Enum.filter(fn x -> x.gpa != nil end)
          |> Enum.map(fn x -> Decimal.to_float(x.gpa) end)
          |> Enum.sum()

        cgpa =
          if total_gpa != 0 do
            (total_gpa / per) |> Float.round(2)
          else
            0
          end

        total_average =
          if total != 0 do
            (total / total_per * 100) |> Float.round(2)
          else
            0
          end

        %{
          subject: new |> elem(1) |> Enum.sort_by(fn x -> x.subject_code end),
          name: name,
          chinese_name: chinese_name,
          sex: sex,
          student_id: student_id,
          total_mark: total,
          per: per,
          total_per: total_per,
          total_average: total_average,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          f: f,
          g: g,
          cgpa: cgpa,
          class_id: class_id
        }
      end
      |> Enum.group_by(fn x -> x.class_id end)

    g =
      for group <- z do
        a =
          group
          |> elem(1)
          |> Enum.sort_by(fn x -> x.total_mark end)
          |> Enum.reverse()
          |> Enum.with_index()

        for item <- a do
          rank = item |> elem(1)
          item = item |> elem(0)
          rank = rank + 1

          %{
            subject: item.subject,
            name: item.name,
            chinese_name: item.chinese_name,
            sex: item.sex,
            student_id: item.student_id,
            total_mark: item.total_mark,
            per: item.per,
            total_per: item.total_per,
            total_average: item.total_average,
            a: item.a,
            b: item.b,
            c: item.c,
            d: item.d,
            e: item.e,
            f: item.f,
            g: item.g,
            cgpa: item.cgpa,
            class_id: item.class_id,
            class_rank: rank
          }
        end
      end
      |> List.flatten()
      |> Enum.sort_by(fn x -> x.total_mark end)
      |> Enum.reverse()
      |> Enum.with_index()

    t =
      for item <- g do
        rank = item |> elem(1)
        item = item |> elem(0)
        rank = rank + 1

        %{
          subject: item.subject,
          name: item.name,
          chinese_name: item.chinese_name,
          sex: item.sex,
          student_id: item.student_id,
          total_mark: item.total_mark,
          per: item.per,
          total_per: item.total_per,
          total_average: item.total_average,
          a: item.a,
          b: item.b,
          c: item.c,
          d: item.d,
          e: item.e,
          f: item.f,
          g: item.g,
          cgpa: item.cgpa,
          class_id: item.class_id,
          class_rank: item.class_rank,
          all_rank: rank
        }
      end
      |> Enum.sort_by(fn x -> x.name end)
      |> Enum.with_index()

    mark = mark1 |> Enum.group_by(fn x -> x.subject_code end)

    institution =
      Repo.get_by(School.Settings.Institution, %{
        id: conn.private.plug_session["institution_id"]
      })

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "standard_ranking.html",
        z: t,
        exam_name: exam_name,
        mark: mark,
        mark1: mark1,
        exam_id: params["exam_standard_result_id"],
        level_id: params["standard_id"],
        csrf: params["csrf"],
        level: level,
        institution: institution
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

  def sorting(conn, male) do
    all =
      if conn.private.plug_session["institution_id"] == 3 do
        m =
          male
          |> Enum.group_by(fn x -> x.sex end)
          |> Enum.filter(fn x -> x |> elem(0) == "M" end)
          |> Enum.map(fn x -> x |> elem(1) end)
          |> List.flatten()

        a =
          for item <- m do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              id: item.id,
              id_no: item.id_no,
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              sex: item.sex
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)

        f =
          male
          |> Enum.group_by(fn x -> x.sex end)
          |> Enum.filter(fn x -> x |> elem(0) == "F" end)
          |> Enum.map(fn x -> x |> elem(1) end)
          |> List.flatten()

        b =
          for item <- f do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              id: item.id,
              id_no: item.id_no,
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              sex: item.sex
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)

        all = a ++ b
      else
        a =
          for item <- male do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              id: item.id,
              id_no: item.id_no,
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              sex: item.sex
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)
      end
  end

  def student_class_listing(conn, params) do
    class_id = params["class_id"]
    semester_id = params["semester_id"]

    if conn.private.plug_session["institution_id"] == 9 or
         conn.private.plug_session["institution_id"] == 10 do
      male =
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
                    s.semester_id == ^semester_id,
                select: %{
                  id: s.sudent_id,
                  id_no: r.student_no,
                  chinese_name: r.chinese_name,
                  name: r.name,
                  sex: r.sex
                },
                order_by: [asc: r.name]
              )
            )
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
                    s.semester_id == ^semester_id,
                select: %{
                  id: s.sudent_id,
                  id_no: r.student_no,
                  chinese_name: r.chinese_name,
                  name: r.name,
                  sex: r.sex
                },
                order_by: [asc: r.name]
              )
            )
        end

      all = male

      all = sorting(conn, all)

      number = 40

      add = number - (all |> Enum.count())

      range = 1..add

      empty_colum =
        for item <- range do
          %{
            id: "",
            id_no: "",
            chinese_name: "",
            name: "",
            sex: ""
          }
        end

      all = (all ++ empty_colum) |> Enum.with_index()

      institution =
        Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

      semester =
        Repo.get_by(
          School.Affairs.Semester,
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

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "student_class_listing.html",
          all: all,
          class: class,
          semester: semester,
          institution: institution
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
    else
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
                  id: s.sudent_id,
                  id_no: r.student_no,
                  chinese_name: r.chinese_name,
                  name: r.name,
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
                  id: s.sudent_id,
                  id_no: r.student_no,
                  chinese_name: r.chinese_name,
                  name: r.name,
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
                  id: s.sudent_id,
                  id_no: r.student_no,
                  chinese_name: r.chinese_name,
                  name: r.name,
                  sex: r.sex
                },
                order_by: [asc: r.name]
              )
            )

          {male, female}
        end

      all = male ++ female

      all = sorting(conn, all)

      number = 40

      add = number - (all |> Enum.count())

      range = 1..add

      empty_colum =
        for item <- range do
          %{
            id: "",
            id_no: "",
            chinese_name: "",
            name: "",
            sex: ""
          }
        end

      all = (all ++ empty_colum) |> Enum.with_index()

      institution =
        Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

      semester =
        Repo.get_by(
          School.Affairs.Semester,
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

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "student_class_listing.html",
          all: all,
          class: class,
          semester: semester,
          institution: institution
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
  end

  def sorting_jpn(conn, male) do
    all =
      if conn.private.plug_session["institution_id"] == 3 do
        m =
          male
          |> Enum.group_by(fn x -> x.sex end)
          |> Enum.filter(fn x -> x |> elem(0) == "M" end)
          |> Enum.map(fn x -> x |> elem(1) end)
          |> List.flatten()

        a =
          for item <- m do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              id: item.id,
              id_no: item.id_no,
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              sex: item.sex,
              dob: item.dob,
              pob: item.pob,
              race: item.race,
              b_cert: item.b_cert,
              register_date: item.register_date
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)

        f =
          male
          |> Enum.group_by(fn x -> x.sex end)
          |> Enum.filter(fn x -> x |> elem(0) == "F" end)
          |> Enum.map(fn x -> x |> elem(1) end)
          |> List.flatten()

        b =
          for item <- f do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              id: item.id,
              id_no: item.id_no,
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              sex: item.sex,
              dob: item.dob,
              pob: item.pob,
              race: item.race,
              b_cert: item.b_cert,
              register_date: item.register_date
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)

        all = a ++ b
      else
        a =
          for item <- male do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              id: item.id,
              id_no: item.id_no,
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              sex: item.sex,
              dob: item.dob,
              pob: item.pob,
              race: item.race,
              b_cert: item.b_cert,
              register_date: item.register_date
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)
      end
  end

  def student_class_listing_jpn(conn, params) do
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

    all = sorting_jpn(conn, all)

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
            id: item.id,
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
            id: "",
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

      all = (new_all ++ empty_colum) |> Enum.with_index()

      institution =
        Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

      semester =
        Repo.get_by(
          School.Affairs.Semester,
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

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "student_class_listing_jpn.html",
          all: all,
          class: class,
          semester: semester,
          institution: institution
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
            id: item.id,
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
            id: "",
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

      all = (new_all ++ empty_colum) |> Enum.with_index()

      institution =
        Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

      semester =
        Repo.get_by(
          School.Affairs.Semester,
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

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "student_class_listing_jpn.html",
          all: all,
          class: class,
          semester: semester,
          institution: institution
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
  end

  def sorting_parent(conn, male) do
    all =
      if conn.private.plug_session["institution_id"] == 3 do
        m =
          male
          |> Enum.group_by(fn x -> x.sex end)
          |> Enum.filter(fn x -> x |> elem(0) == "M" end)
          |> Enum.map(fn x -> x |> elem(1) end)
          |> List.flatten()

        a =
          for item <- m do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              icno: item.ic,
              b_cert: item.b_cert,
              line1: item.line1,
              line2: item.line2,
              postcode: item.postcode,
              town: item.town,
              state: item.state,
              country: item.country,
              ficno: item.ficno,
              micno: item.micno
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)

        f =
          male
          |> Enum.group_by(fn x -> x.sex end)
          |> Enum.filter(fn x -> x |> elem(0) == "F" end)
          |> Enum.map(fn x -> x |> elem(1) end)
          |> List.flatten()

        b =
          for item <- f do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              icno: item.ic,
              b_cert: item.b_cert,
              line1: item.line1,
              line2: item.line2,
              postcode: item.postcode,
              town: item.town,
              state: item.state,
              country: item.country,
              ficno: item.ficno,
              micno: item.micno
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)

        all = a ++ b
      else
        a =
          for item <- male do
            ori_name = item.name

            sort_name = item.name |> String.replace("'", "A")

            %{
              chinese_name: item.chinese_name,
              name: ori_name,
              sort_name: sort_name,
              icno: item.icno,
              b_cert: item.b_cert,
              line1: item.line1,
              line2: item.line2,
              postcode: item.postcode,
              town: item.town,
              state: item.state,
              country: item.country,
              ficno: item.ficno,
              micno: item.micno
            }
          end
          |> Enum.sort_by(fn x -> x.sort_name end)
      end
  end

  def student_class_listing_parent(conn, params) do
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

    all = sorting_parent(conn, all)

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

    all = (all ++ empty_colum) |> Enum.with_index()

    institution =
      Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

    semester =
      Repo.get_by(
        School.Affairs.Semester,
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

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "student_class_listing_parent.html",
        all: all,
        class: class,
        semester: semester,
        institution: institution
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

  def class_assessment(conn, params) do
    inst_id = conn.private.plug_session["institution_id"]
    institution = Repo.get_by(School.Settings.Institution, id: inst_id)

    mark =
      Repo.all(
        from(
          s in School.Affairs.AssessmentMark,
          where:
            s.institution_id == ^inst_id and s.class_id == ^params["class"] and
              s.semester_id == ^params["semester"]
        )
      )
      |> Enum.group_by(fn x -> x.student_id end)

    semester =
      Repo.get_by(
        School.Affairs.Semester,
        id: params["semester"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    class = Repo.get_by(School.Affairs.Class, id: params["class"])

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "student_assessment.html",
        mark: mark,
        class: class,
        semester: semester,
        institution: institution
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

  def teacher_listing(conn, params) do
    inst_id = conn.private.plug_session["institution_id"]

    institution = Repo.get_by(School.Settings.Institution, id: inst_id)

    teacher =
      Repo.all(
        from(
          s in School.Affairs.Teacher,
          where: s.institution_id == ^inst_id and s.is_delete != 1,
          select: %{name: s.name, cname: s.cname},
          order_by: [asc: s.rank, asc: s.name]
        )
      )

    number = 40

    add = number - (teacher |> Enum.count())

    range = 1..add

    empty_colum =
      for item <- range do
        %{
          name: "",
          cname: ""
        }
      end

    teacher = (teacher ++ empty_colum) |> Enum.with_index()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "teacher_listing.html",
        teacher: teacher,
        institution: institution
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

  def exam_result_analysis_class(conn, params) do
    flag = params["flag"] |> String.to_integer()
    year = params["year"]
    sem = params["sem"]
    class_id = params["class_id"]
    standard_id = params["standard_id"]
    inst_id = params["institution_id"] |> String.to_integer()

    institution =
      Repo.all(
        from(
          c in School.Settings.Institution,
          where: c.id == ^inst_id,
          select: %{name: c.name}
        )
      )
      |> hd

    level_id =
      if flag == 2 do
        level_id =
          Repo.all(
            from(
              c in School.Affairs.Class,
              where: c.level_id == ^standard_id,
              select: %{class_name: c.name}
            )
          )
          |> Enum.map(fn x -> x.class_name end)
      end

    new_mark =
      cond do
        sem == "ALL SEMESTER" && flag == 1 ->
          new_mark =
            Repo.all(
              from(
                m in School.Affairs.MarkSheetTemp,
                left_join: c in School.Affairs.Class,
                on: c.name == m.class,
                where: m.institution_id == ^inst_id and m.year == ^year and m.class == ^class_id,
                select: %{
                  student_id: m.stuid,
                  name: m.name,
                  semester: m.semester,
                  class: m.class,
                  code: m.subject,
                  m1: m.s1m,
                  g1: m.s1g
                }
              )
            )
            |> Enum.uniq()
            |> Enum.group_by(fn x -> x.name end)

        sem == "ALL SEMESTER" && flag == 2 ->
          new_mark =
            Repo.all(
              from(
                m in School.Affairs.MarkSheetTemp,
                left_join: c in School.Affairs.Class,
                on: c.name == m.class,
                where: m.institution_id == ^inst_id and m.year == ^year and m.class in ^level_id,
                select: %{
                  student_id: m.stuid,
                  name: m.name,
                  semester: m.semester,
                  class: m.class,
                  code: m.subject,
                  m1: m.s1m,
                  g1: m.s1g
                }
              )
            )
            |> Enum.uniq()
            |> Enum.group_by(fn x -> x.name end)

        sem != "ALL SEMESTER" && flag == 1 ->
          new_mark =
            Repo.all(
              from(
                m in School.Affairs.MarkSheetTemp,
                left_join: c in School.Affairs.Class,
                on: c.name == m.class,
                where:
                  m.institution_id == ^inst_id and m.year == ^year and m.semester == ^sem and
                    m.class == ^class_id,
                select: %{
                  student_id: m.stuid,
                  name: m.name,
                  semester: m.semester,
                  class: m.class,
                  code: m.subject,
                  m1: m.s1m,
                  g1: m.s1g
                }
              )
            )
            |> Enum.uniq()
            |> Enum.group_by(fn x -> x.name end)

        sem != "ALL SEMESTER" && flag == 2 ->
          new_mark =
            Repo.all(
              from(
                m in School.Affairs.MarkSheetTemp,
                left_join: c in School.Affairs.Class,
                on: c.name == m.class,
                where:
                  m.institution_id == ^inst_id and m.year == ^year and m.semester == ^sem and
                    m.class in ^level_id,
                select: %{
                  student_id: m.stuid,
                  name: m.name,
                  semester: m.semester,
                  class: m.class,
                  code: m.subject,
                  m1: m.s1m,
                  g1: m.s1g
                }
              )
            )
            |> Enum.uniq()
            |> Enum.group_by(fn x -> x.name end)
      end

    html =
      if new_mark != %{} do
        html =
          Phoenix.View.render_to_string(
            SchoolWeb.PdfView,
            "exam_result_analysis_by_class.html",
            new_mark: new_mark,
            inst_id: inst_id,
            flag: flag,
            year: year,
            sem: sem,
            class_id: class_id,
            standard_id: standard_id,
            csrf: params["csrf"],
            institution: institution
          )
      else
        html = "No Data Inside"
      end

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
          "utf-8",
          "--orientation",
          "Portrait"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def exam_result_analysis_class_standard(conn, params) do
    standard_id = params["standard_id"]
    subject_id = params["subject_id"]
    institution_id = params["institution_id"]
    institution_name = params["institution_name"]
    year = params["year"]
    e_year = params["e_year"]

    keys =
      Map.keys(params)
      |> Enum.filter(fn x ->
        x != "standard_id" and x != "subject_id" and x != "institution_id" and
          x != "institution_name" and x != "year" and x != "e_year" and x != "exam_count" and
          x != "_csrf_token"
      end)

    exam_id =
      for a <- keys do
        id = params[a]
      end

    standard =
      Repo.get_by(School.Affairs.Level, %{
        id: standard_id,
        institution_id: institution_id
      })

    subject =
      Repo.get_by(School.Affairs.Subject, %{
        id: subject_id,
        institution_id: institution_id
      })

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          left_join: p in School.Affairs.Subject,
          on: s.subject_id == p.id,
          left_join: k in School.Affairs.Exam,
          on: s.exam_id == k.id,
          left_join: t in School.Affairs.ExamMaster,
          on: k.exam_master_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          left_join: d in School.Affairs.Level,
          on: r.level_id == d.id,
          where:
            t.id in ^exam_id and t.year == ^e_year and r.level_id == ^standard_id and
              p.id == ^subject_id,
          select: %{
            class_name: r.name,
            subject_code: p.code,
            exam_name: t.name,
            student_id: s.student_id,
            mark: s.mark
          }
        )
      )
      |> Enum.filter(fn x -> x.mark != nil end)

    all_mark = all |> Enum.group_by(fn x -> x.class_name end)

    grades =
      Repo.all(
        from(
          g in School.Affairs.ExamGrade,
          left_join: e in School.Affairs.Exam,
          on: g.exam_master_id == e.exam_master_id,
          where: g.institution_id == ^institution_id and e.subject_id == ^subject_id
        )
      )

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(1) |> Enum.map(fn x -> x.subject_code end) |> Enum.uniq()

        datas = item |> elem(1)

        for data <- datas do
          student_mark = student_mark = data.mark |> Decimal.to_float()

          for grade <- grades do
            if student_mark >= grade.min |> Decimal.to_float() &&
                 student_mark <= grade.max |> Decimal.to_float() do
              %{
                student_id: data.student_id,
                grade: grade.name,
                gpa: grade.gpa,
                subject_code: subject_code,
                student_mark: student_mark,
                class_name: data.class_name,
                exam_name: data.exam_name
              }
            end
          end
        end
      end
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.uniq()

    group = mark1 |> Enum.group_by(fn x -> {x.class_name, x.exam_name} end)
    all = mark1 |> Enum.group_by(fn x -> x.exam_name end)

    group_exam =
      for item <- all do
        g_total_student = item |> elem(1) |> Enum.count()
        g_a = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        g_b = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        g_c = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        g_d = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        g_e = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)

        g_exam_name = item |> elem(1) |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq()

        g_lulus = g_a + g_b + g_c + g_d
        g_fail = g_e

        %{
          g_exam_name: g_exam_name,
          g_total_student: g_total_student,
          g_a: g_a,
          g_b: g_b,
          g_c: g_c,
          g_d: g_d,
          g_e: g_e,
          g_lulus: g_lulus,
          g_tak_lulus: g_fail
        }
      end

    g_a = group_exam |> Enum.map(fn x -> x.g_a end) |> Enum.sum()
    g_b = group_exam |> Enum.map(fn x -> x.g_b end) |> Enum.sum()
    g_c = group_exam |> Enum.map(fn x -> x.g_c end) |> Enum.sum()
    g_d = group_exam |> Enum.map(fn x -> x.g_d end) |> Enum.sum()
    g_e = group_exam |> Enum.map(fn x -> x.g_e end) |> Enum.sum()
    g_lulus = group_exam |> Enum.map(fn x -> x.g_lulus end) |> Enum.sum()
    g_fail = group_exam |> Enum.map(fn x -> x.g_tak_lulus end) |> Enum.sum()
    g_total_student = group_exam |> Enum.map(fn x -> x.g_total_student end) |> Enum.sum()

    group_subject =
      for item <- group do
        total_student = item |> elem(1) |> Enum.count()
        a = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        kelas = item |> elem(1) |> Enum.map(fn x -> x.class_name end) |> Enum.uniq()
        exam_name = item |> elem(1) |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq()

        lulus = a + b + c + d
        fail = e

        %{
          exam_name: exam_name,
          total_student: total_student,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          lulus: lulus,
          tak_lulus: fail,
          kelas: kelas
        }
      end

    a = group_subject |> Enum.map(fn x -> x.a end) |> Enum.sum()
    b = group_subject |> Enum.map(fn x -> x.b end) |> Enum.sum()
    c = group_subject |> Enum.map(fn x -> x.c end) |> Enum.sum()
    d = group_subject |> Enum.map(fn x -> x.d end) |> Enum.sum()
    e = group_subject |> Enum.map(fn x -> x.e end) |> Enum.sum()
    lulus = group_subject |> Enum.map(fn x -> x.lulus end) |> Enum.sum()
    tak_lulus = group_subject |> Enum.map(fn x -> x.tak_lulus end) |> Enum.sum()
    total = group_subject |> Enum.map(fn x -> x.total_student end) |> Enum.sum()

    group_subject = group_subject |> Enum.sort_by(fn x -> x.exam_name end)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "result_analysis_by_standard.html",
        group_subject: group_subject,
        standard: standard,
        subject_name: subject.description,
        group_exam: group_exam,
        institution_name: institution_name,
        year: year
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
          "utf-8",
          "--orientation",
          "Portrait"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

  def student_list_by_co(conn, params) do
    inst_id = conn.private.plug_session["institution_id"]
    institution = Repo.get_by(School.Settings.Institution, id: inst_id)

    cocurriculum = params["cocurriculum_id"]
    coco_details = Repo.get_by(School.Affairs.CoCurriculum, id: cocurriculum)
    co_level = params["standard_id"]
    co_semester = params["semester_id"]
    class = params["class"]
    class = String.graphemes(class)
    sort_by = params["sort_by"]
    type = params["type"]
    IO.inspect(sort_by)

    sort_by =
      if sort_by != "nil" do
        sort_by = String.to_integer(sort_by)
      else
        sort_by
      end

    IO.inspect(sort_by)

    sem = Repo.get(Semester, co_semester)

    students1 =
      Repo.all(
        from(
          s in School.Affairs.StudentCocurriculum,
          left_join: a in School.Affairs.Student,
          on: s.student_id == a.id,
          left_join: p in School.Affairs.CoCurriculum,
          on: s.cocurriculum_id == p.id,
          where:
            s.cocurriculum_id == ^cocurriculum and s.semester_id == ^co_semester and
              a.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            id: p.id,
            student_id: s.student_id,
            chinese_name: a.chinese_name,
            name: a.name,
            mark: s.mark,
            gender: a.sex,
            race: a.race
          }
        )
      )

    sc =
      if class == [] do
        sc =
          Repo.all(
            from(
              s in Student,
              left_join: sc in StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in Class,
              on: c.id == sc.class_id,
              where: sc.institute_id == ^sem.institution_id and sc.semester_id == ^co_semester,
              select: %{
                student_id: s.id,
                class: c.name,
                class_id: c.id,
                level_id: sc.level_id
              }
            )
          )
      else
        sc =
          Repo.all(
            from(
              s in Student,
              left_join: sc in StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in Class,
              on: c.id == sc.class_id,
              where:
                c.id in ^class and sc.institute_id == ^sem.institution_id and
                  sc.semester_id == ^co_semester,
              select: %{
                student_id: s.id,
                class: c.name,
                class_id: c.id,
                level_id: sc.level_id
              }
            )
          )
      end

    students =
      for student <- students1 do
        if Enum.any?(sc, fn x -> x.student_id == student.student_id end) do
          b = sc |> Enum.filter(fn x -> x.student_id == student.student_id end) |> hd()

          student = Map.put(student, :class_name, b.class)
          student = Map.put(student, :class_id, b.class_id)
          student = Map.put(student, :level_id, b.level_id)
          student
        else
          student = Map.put(student, :class_name, "no class assigned")
          student = Map.put(student, :level_id, 0)
          student
        end
      end

    students = students |> Enum.filter(fn x -> x.class_name != "no class assigned" end)

    students =
      if co_level != "Choose a level" do
        students |> Enum.filter(fn x -> x.level_id == String.to_integer(co_level) end)
      else
        students
      end

    students =
      if sort_by == 3 do
        students |> Enum.sort_by(fn d -> d.name end)
      else
        students
      end

    students =
      if sort_by == 2 do
        students |> Enum.sort_by(fn d -> {d.class_name, d.name} end)
      else
        students
      end

    students =
      if sort_by == 1 do
        students |> Enum.sort_by(fn d -> {d.class_name, d.id} end)
      else
        students
      end

    summary = %{}

    summary =
      if type == "1" do
        male = Enum.filter(students, fn x -> x.gender == "Male" end)
        male_chinese = Enum.count(male, fn x -> x.race == "Chinese" end)
        male_malay = Enum.count(male, fn x -> x.race == "Malay" end)
        male_indian = Enum.count(male, fn x -> x.race == "Indian" end)
        #  male_other = Enum.count(male, fn x -> x.race == "other" end)

        female = Enum.filter(students, fn x -> x.gender == "Female" end)
        female_chinese = Enum.count(female, fn x -> x.race == "Chinese" end)
        female_malay = Enum.count(female, fn x -> x.race == "Malay" end)
        female_indian = Enum.count(female, fn x -> x.race == "Indian" end)
        # female_other = Enum.count(female, fn x -> x.race == "other" end)
        tot_chinese = male_chinese + female_chinese
        tot_indian = male_indian + female_indian
        tot_malay = male_malay + female_malay
        tot_std = tot_chinese + tot_malay + tot_indian

        # summary = Map.put(summary, :male, male)
        summary = Map.put(summary, :male_chinese, male_chinese)
        summary = Map.put(summary, :male_malay, male_malay)
        summary = Map.put(summary, :male_indian, male_indian)
        # Map.put(summary, :male_other, male_other)

        # summary = Map.put(summary, :female, female)
        summary = Map.put(summary, :female_chinese, female_chinese)
        summary = Map.put(summary, :female_malay, female_malay)
        summary = Map.put(summary, :female_indian, female_indian)

        summary = Map.put(summary, :tot_chinese, tot_chinese)
        summary = Map.put(summary, :tot_indian, tot_indian)
        summary = Map.put(summary, :tot_malay, tot_malay)
        summary = Map.put(summary, :tot_std, tot_std)

        # Map.put(summary, :female_other, female_other)
        summary
      else
        summary
      end

    html =
      if type == "1" do
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "student_listing_by_cocurriculum.html",
          students: students,
          summary: summary,
          institution: institution,
          coco_details: coco_details
        )
      else
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "student2_listing_by_cocurriculum.html",
          students: students,
          institution: institution,
          coco_details: coco_details
        )
      end

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

  def holiday_listing(conn, params) do
    ins_id = conn.private.plug_session["institution_id"]
    semester_id = params["semester"] |> String.to_integer()
    institution = Repo.get_by(School.Settings.Institution, id: ins_id)

    holiday =
      Affairs.list_holiday()
      |> Enum.filter(fn x -> x.institution_id == ins_id end)
      |> Enum.filter(fn x -> x.semester_id == semester_id end)

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "holiday_report.html",
        holiday: holiday,
        institution: institution
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

  def exam_result_class_pdf(conn, params) do
    class_id = params["class_id"] |> String.to_integer()
    exam_no = params["exam_no"]
    year = params["year"]
    type = params["type"]

    student_class =
      Repo.all(
        from(
          s in School.Affairs.Student,
          left_join: g in School.Affairs.StudentClass,
          on: s.id == g.sudent_id,
          left_join: k in School.Affairs.Class,
          on: k.id == g.class_id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              g.semester_id == ^conn.private.plug_session["semester_id"] and
              g.class_id == ^params["class_id"],
          select: %{
            student_id: s.id,
            student_name: s.name,
            chinese_name: s.chinese_name,
            class_name: k.name
          }
        )
      )

    class =
      Repo.get_by(
        School.Affairs.Class,
        id: params["class_id"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    exam_mast =
      Repo.get_by(
        School.Affairs.ExamMaster,
        exam_no: params["exam_no"],
        level_id: class.level_id,
        institution_id: conn.private.plug_session["institution_id"]
      )

    marks =
      Repo.all(
        from(
          s in School.Affairs.MarkSheetTemp,
          where:
            s.class == ^class.name and
              s.institution_id == ^conn.private.plug_session["institution_id"] and s.year == ^year
        )
      )

    atten =
      case exam_no do
        "1" ->
          all = marks |> Enum.filter(fn x -> x.s1g == "TH" end)

          if all != [] do
            total =
              all
              |> Enum.group_by(fn x -> x.stuid end)
              |> Enum.count()
          else
            0
          end

        "2" ->
          ""

        "3" ->
          ""

        "4" ->
          ""
      end

    fail =
      case exam_no do
        "1" ->
          all_e =
            marks
            |> Enum.filter(fn x -> x.s1g == "E" and x.subject != "AGM" and x.subject != "PM" end)

          all_th =
            marks
            |> Enum.filter(fn x -> x.s1g == "TH" end)

          all = all_e ++ all_th
          # agm = marks |> Enum.filter(fn x -> x.subject == "AGM" and x.s1m != "0" end)

          # agmf =
          #   marks
          #   |> Enum.filter(fn x -> x.subject == "AGM" and x.s1m != "0" or x.s1g == "E" end)

          # agm = agm - agmf

          # agm = agm |> Enum.filter(fn x -> x.s1g == "E" end)

          # pm =
          #   marks |> Enum.filter(fn x -> x.subject == "PM" and x.s1m == "0" end) |> Enum.count()

          # pmf =
          #   marks
          #   |> Enum.filter(fn x -> x.subject == "PM" and x.s1m != "0" end)
          #   |> Enum.count()

          # pm = pm - pmf

          # tt = agm + pm

          if all != [] do
            total =
              all
              |> Enum.group_by(fn x -> x.stuid end)
              |> Enum.count()

            total = total
          else
            0
          end

        "2" ->
          ""

        "3" ->
          ""

        "4" ->
          ""
      end

    pass =
      case exam_no do
        "1" ->
          all =
            marks
            |> Enum.group_by(fn x -> x.stuid end)
            |> Enum.count()

          xhdir =
            marks
            |> Enum.filter(fn x -> x.s1g == "TH" end)
            |> Enum.group_by(fn x -> x.stuid end)
            |> Enum.count()

          if all != [] do
            IO.puts("no of all students #{all} at 7106")
            IO.puts("no of failed students #{fail}")
            total = all - fail
          else
            0
          end

        "2" ->
          ""

        "3" ->
          ""

        "4" ->
          ""
      end

    # for item <- marks |> Enum.group_by(fn x -> x.stuid end) do

    #   item|>elem(1)
    #   IEx.pry()
    # end

    examdata =
      case exam_no do
        "1" ->
          a =
            a =
            for sd <- student_class do
              name = sd.student_name <> "   " <> sd.chinese_name

              bcf =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BCF"
                end)

              bcf =
                if bcf != [] do
                  a = bcf |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bct =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BCT"
                end)

              bct =
                if bct != [] do
                  a = bct |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bcl =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BCL"
                end)

              bcl =
                if bcl != [] do
                  a = bcl |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              bmf =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BMF"
                end)

              bmf =
                if bmf != [] do
                  a = bmf |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bmt =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BMT"
                end)

              bmt =
                if bmt != [] do
                  a = bmt |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bml =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BML"
                end)

              bml =
                if bml != [] do
                  a = bml |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              bif =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BIF"
                end)

              bif =
                if bif != [] do
                  a = bif |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bit =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BIT"
                end)

              bit =
                if bit != [] do
                  a = bit |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bil =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BIL"
                end)

              bil =
                if bil != [] do
                  a = bil |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              math =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "MAT"
                end)

              math =
                if math != [] do
                  a = math |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              sains =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "SN"
                end)

              sains =
                if sains != [] do
                  a = sains |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              sejarah =
                if conn.private.plug_session["institution_id"] != 3 do
                  sejarah =
                    marks
                    |> Enum.filter(fn x ->
                      x.stuid == Integer.to_string(sd.student_id) and x.subject == "SEJ"
                    end)

                  sejarah =
                    if sejarah != [] do
                      a = sejarah |> hd

                      if a.s1g == "TH" do
                        "TH"
                      else
                        a.s1m
                      end
                    else
                      ""
                    end
                else
                  sejarah =
                    marks
                    |> Enum.filter(fn x ->
                      x.stuid == Integer.to_string(sd.student_id) and x.subject == "SEJ"
                    end)

                  sejarah =
                    if sejarah != [] do
                      a = sejarah |> hd

                      if a.s1g == "TH" do
                        "TH"
                      else
                        a.s1g
                      end
                    else
                      ""
                    end
                end

              moral =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PM"
                end)

              moral =
                if moral != [] do
                  a = moral |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    if a.s1m == "0" do
                      ""
                    else
                      a.s1m
                    end
                  end
                else
                  ""
                end

              agama =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "AGM"
                end)

              agama =
                if agama != [] do
                  a = agama |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    if a.s1m == "0" do
                      ""
                    else
                      a.s1m
                    end
                  end
                else
                  ""
                end

              rbt =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "RBT"
                end)

              rbt =
                if rbt != [] do
                  a = rbt |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              tmk =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "TMK"
                end)

              tmk =
                if tmk != [] do
                  a = tmk |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              muzik =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "MZ"
                end)

              muzik =
                if muzik != [] do
                  a = muzik |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              pk =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PK"
                end)

              pk =
                if pk != [] do
                  a = pk |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              pj =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PJ"
                end)

              pj =
                if pj != [] do
                  a = pj |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              seni =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "SENI"
                end)

              seni =
                if seni != [] do
                  a = seni |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              klk =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "KLK"
                end)

              klk =
                if klk != [] do
                  a = klk |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              dsv =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "DSV"
                end)

              dsv =
                if dsv != [] do
                  a = dsv |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              psv =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PSV"
                end)

              psv =
                if psv != [] do
                  a = psv |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              total =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "TOTAL"
                end)

              total =
                if total != [] do
                  a = total |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m |> String.split("/") |> hd
                  end
                else
                  ""
                end

              averg =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "AVERG"
                end)

              averg =
                if averg != [] do
                  a = averg |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m |> String.split("/") |> hd
                  end
                else
                  ""
                end

              {crank, srank} =
                if conn.private.plug_session["institution_id"] == 9 do
                  th_cond =
                    marks
                    |> Enum.filter(fn x ->
                      x.stuid == Integer.to_string(sd.student_id) and x.s1g == "TH"
                    end)

                  {crank, srank} =
                    if th_cond == [] do
                      crank =
                        marks
                        |> Enum.filter(fn x ->
                          x.stuid == Integer.to_string(sd.student_id) and x.subject == "CRANK"
                        end)

                      crank =
                        if crank != [] do
                          a = crank |> hd

                          if a.s1g == "TH" do
                            "TH"
                          else
                            if a.s1m != nil do
                              a.s1m |> String.split("/") |> hd |> String.to_integer()
                            else
                              ""
                            end
                          end
                        else
                          ""
                        end

                      srank =
                        marks
                        |> Enum.filter(fn x ->
                          x.stuid == Integer.to_string(sd.student_id) and x.subject == "SRANK"
                        end)

                      srank =
                        if srank != [] do
                          a = srank |> hd

                          if a.s1g == "TH" do
                            "TH"
                          else
                            if a.s1m != nil do
                              a.s1m |> String.split("/") |> hd |> String.to_integer()
                            else
                              ""
                            end
                          end
                        else
                          ""
                        end

                      {crank, srank}
                    else
                      crank = ""

                      srank = ""

                      {crank, srank}
                    end
                else
                  crank =
                    marks
                    |> Enum.filter(fn x ->
                      x.stuid == Integer.to_string(sd.student_id) and x.subject == "CRANK"
                    end)

                  crank =
                    if crank != [] do
                      a = crank |> hd

                      if a.s1g == "TH" do
                        "TH"
                      else
                        if a.s1m != nil do
                          a.s1m |> String.split("/") |> hd |> String.to_integer()
                        else
                          ""
                        end
                      end
                    else
                      ""
                    end

                  srank =
                    marks
                    |> Enum.filter(fn x ->
                      x.stuid == Integer.to_string(sd.student_id) and x.subject == "SRANK"
                    end)

                  srank =
                    if srank != [] do
                      a = srank |> hd

                      if a.s1g == "TH" do
                        "TH"
                      else
                        if a.s1m != nil do
                          a.s1m |> String.split("/") |> hd |> String.to_integer()
                        else
                          ""
                        end
                      end
                    else
                      ""
                    end

                  {crank, srank}
                end

              all_pass =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id)
                end)

              all_pass =
                if all_pass != [] do
                  got_fail =
                    all_pass
                    |> Enum.filter(fn x ->
                      x.subject != "AGM" and x.subject != "PM"
                    end)
                    |> Enum.any?(fn x -> x.s1g == "E" end)

                  got_th =
                    all_pass
                    |> Enum.filter(fn x ->
                      x.subject != "AGM" and x.subject != "PM"
                    end)
                    |> Enum.any?(fn x -> x.s1g == "TH" end)

                  a =
                    cond do
                      got_th != true && got_fail != true ->
                        true

                      got_th ->
                        false

                      got_fail ->
                        false

                      true ->
                        false
                    end
                end

              aa =
                if conn.private.plug_session["institution_id"] != 9 do
                  psv
                else
                  dsv
                end

              %{
                a: name,
                b: bcl,
                c: bct,
                d: bcf,
                e: bml,
                f: bmt,
                g: bmf,
                h: bil,
                i: bit,
                j: bif,
                k: math,
                l: sains,
                m: moral,
                n: agama,
                o: sejarah,
                p: rbt,
                q: tmk,
                r: aa,
                s: pj,
                sa: pk,
                sb: muzik,
                t: klk,
                u: total,
                v: averg,
                w: crank,
                x: srank,
                y: all_pass
              }
            end

        "2" ->
          "s2m"

        "3" ->
          "s3m"

        "4" ->
          "s4m"
      end

    if type == "PDF(Rank)" do
      institution =
        Repo.get_by(School.Settings.Institution, %{
          id: conn.private.plug_session["institution_id"]
        })

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "exam_result_class.html",
          class: class,
          atten: atten,
          fail: fail,
          pass: pass,
          exam_name: exam_mast.name,
          institution: institution,
          examdata: examdata |> Enum.sort_by(fn x -> x.w end)
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
            "utf-8",
            "--orientation",
            "Landscape"
          ],
          delete_temporary: true
        )

      conn
      |> put_resp_header("Content-Type", "application/pdf")
      |> resp(200, pdf_binary)
    else
      if type == "PDF(Student)" do
        institution =
          Repo.get_by(School.Settings.Institution, %{
            id: conn.private.plug_session["institution_id"]
          })

        html =
          Phoenix.View.render_to_string(
            SchoolWeb.PdfView,
            "exam_result_class.html",
            class: class,
            atten: atten,
            fail: fail,
            pass: pass,
            exam_name: exam_mast.name,
            institution: institution,
            examdata: examdata |> Enum.sort_by(fn x -> x.a end)
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
              "utf-8",
              "--orientation",
              "Landscape"
            ],
            delete_temporary: true
          )

        conn
        |> put_resp_header("Content-Type", "application/pdf")
        |> resp(200, pdf_binary)
      else
        gg =
          if conn.private.plug_session["institution_id"] != 9 do
            "PSV"
          else
            "DSV"
          end

        csv_content = [
          "Name",
          "BCL",
          "BCF",
          "BCT",
          "BML",
          "BMF",
          "BMT",
          "BIL",
          "BIF",
          "BIT",
          "MAT",
          "SN",
          "PM",
          "AGM",
          "SEJ",
          "RBT",
          "TMK",
          gg,
          "PJ",
          "PK",
          "MZ",
          "KLK",
          "总分",
          "平均",
          "KDK",
          "KDD"
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
          for item <- examdata |> Enum.sort_by(fn x -> x.k end) |> Enum.with_index() do
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

        data =
          if data == [] do
            [{"A2", "No Data"}]
          else
            data
          end

        final = header ++ data

        sheet = Sheet.with_name("ExamResultClass")

        total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

        total =
          total
          |> Sheet.set_col_width("A", 50.0)

        page = %Workbook{sheets: [total]}

        image_path = Application.app_dir(:school, "priv/static/images")
        path = File.cwd!() <> "/media"
        content = page |> Elixlsx.write_to(image_path <> "/ExamResultClass.xlsx")

        file = File.read!(image_path <> "/ExamResultClass.xlsx")

        conn
        |> put_resp_content_type("text/xlsx")
        |> put_resp_header(
          "content-disposition",
          "attachment; filename=\"ExamResultClass-#{class.name}.xlsx\""
        )
        |> send_resp(200, file)
      end
    end
  end

  def exam_result_standard_pdf(conn, params) do
    level_id = params["level_id"] |> String.to_integer()
    exam_no = params["exam_no"]
    year = params["year"]
    type = params["type"]

    student_class =
      Repo.all(
        from(
          s in School.Affairs.Student,
          left_join: g in School.Affairs.StudentClass,
          on: s.id == g.sudent_id,
          left_join: k in School.Affairs.Class,
          on: k.id == g.class_id,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              g.semester_id == ^conn.private.plug_session["semester_id"] and
              k.level_id == ^params["level_id"],
          select: %{
            student_id: s.id,
            student_name: s.name,
            chinese_name: s.chinese_name,
            class_name: k.name
          }
        )
      )

    standard =
      Repo.get_by(
        School.Affairs.Level,
        id: params["level_id"],
        institution_id: conn.private.plug_session["institution_id"]
      )

    exam_mast =
      Repo.get_by(
        School.Affairs.ExamMaster,
        exam_no: params["exam_no"],
        level_id: level_id,
        institution_id: conn.private.plug_session["institution_id"]
      )

    list_class =
      Repo.all(from(s in School.Affairs.Class, where: s.level_id == ^level_id, select: s.name))

    class = ""

    marks =
      Repo.all(
        from(
          s in School.Affairs.MarkSheetTemp,
          where:
            s.class in ^list_class and
              s.institution_id == ^conn.private.plug_session["institution_id"] and s.year == ^year
        )
      )

    atten =
      case exam_no do
        "1" ->
          all = marks |> Enum.filter(fn x -> x.s1g == "TH" end)

          if all != [] do
            total = all |> Enum.group_by(fn x -> x.stuid end) |> Enum.count()
          else
            0
          end

        "2" ->
          ""

        "3" ->
          ""

        "4" ->
          ""
      end

    fail =
      case exam_no do
        "1" ->
          all_e =
            marks
            |> Enum.filter(fn x -> x.s1g == "E" and x.subject != "AGM" and x.subject != "PM" end)

          all_th =
            marks
            |> Enum.filter(fn x -> x.s1g == "TH" end)

          all = all_e ++ all_th
          # agm = marks |> Enum.filter(fn x -> x.subject == "AGM" and x.s1m != "0" end)

          # agmf =
          #   marks
          #   |> Enum.filter(fn x -> x.subject == "AGM" and x.s1m != "0" or x.s1g == "E" end)

          # agm = agm - agmf

          # agm = agm |> Enum.filter(fn x -> x.s1g == "E" end)

          # pm =
          #   marks |> Enum.filter(fn x -> x.subject == "PM" and x.s1m == "0" end) |> Enum.count()

          # pmf =
          #   marks
          #   |> Enum.filter(fn x -> x.subject == "PM" and x.s1m != "0" end)
          #   |> Enum.count()

          # pm = pm - pmf

          # tt = agm + pm

          if all != [] do
            total =
              all
              |> Enum.group_by(fn x -> x.stuid end)
              |> Enum.count()

            total = total
          else
            0
          end

        "2" ->
          ""

        "3" ->
          ""

        "4" ->
          ""
      end

    pass =
      case exam_no do
        "1" ->
          all =
            marks
            |> Enum.group_by(fn x -> x.stuid end)
            |> Enum.count()

          xhdir =
            marks
            |> Enum.filter(fn x -> x.s1g == "TH" end)
            |> Enum.group_by(fn x -> x.stuid end)
            |> Enum.count()

          if all != [] do
            IO.puts("no of all students #{all}")
            IO.puts("no of failed students #{fail}")
            total = all - fail
          else
            0
          end

        "2" ->
          ""

        "3" ->
          ""

        "4" ->
          ""
      end

    examdata =
      case exam_no do
        "1" ->
          a =
            a =
            for sd <- student_class do
              name = sd.student_name <> "   " <> sd.chinese_name

              bcf =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BCF"
                end)

              bcf =
                if bcf != [] do
                  a = bcf |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bct =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BCT"
                end)

              bct =
                if bct != [] do
                  a = bct |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bcl =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BCL"
                end)

              bcl =
                if bcl != [] do
                  a = bcl |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              bmf =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BMF"
                end)

              bmf =
                if bmf != [] do
                  a = bmf |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bmt =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BMT"
                end)

              bmt =
                if bmt != [] do
                  a = bmt |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bml =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BML"
                end)

              bml =
                if bml != [] do
                  a = bml |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              bif =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BIF"
                end)

              bif =
                if bif != [] do
                  a = bif |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bit =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BIT"
                end)

              bit =
                if bit != [] do
                  a = bit |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              bil =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "BIL"
                end)

              bil =
                if bil != [] do
                  a = bil |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              math =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "MAT"
                end)

              math =
                if math != [] do
                  a = math |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              sains =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "SN"
                end)

              sains =
                if sains != [] do
                  a = sains |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m
                  end
                else
                  ""
                end

              sejarah =
                if conn.private.plug_session["institution_id"] != 3 do
                  sejarah =
                    marks
                    |> Enum.filter(fn x ->
                      x.stuid == Integer.to_string(sd.student_id) and x.subject == "SEJ"
                    end)

                  sejarah =
                    if sejarah != [] do
                      a = sejarah |> hd

                      if a.s1g == "TH" do
                        "TH"
                      else
                        a.s1m
                      end
                    else
                      ""
                    end
                else
                  sejarah =
                    marks
                    |> Enum.filter(fn x ->
                      x.stuid == Integer.to_string(sd.student_id) and x.subject == "SEJ"
                    end)

                  sejarah =
                    if sejarah != [] do
                      a = sejarah |> hd

                      if a.s1g == "TH" do
                        "TH"
                      else
                        a.s1g
                      end
                    else
                      ""
                    end
                end

              moral =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PM"
                end)

              moral =
                if moral != [] do
                  a = moral |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    if a.s1m == "0" do
                      ""
                    else
                      a.s1m
                    end
                  end
                else
                  ""
                end

              agama =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "AGM"
                end)

              agama =
                if agama != [] do
                  a = agama |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    if a.s1m == "0" do
                      ""
                    else
                      a.s1m
                    end
                  end
                else
                  ""
                end

              rbt =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "RBT"
                end)

              rbt =
                if rbt != [] do
                  a = rbt |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              tmk =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "TMK"
                end)

              tmk =
                if tmk != [] do
                  a = tmk |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              muzik =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "MZ"
                end)

              muzik =
                if muzik != [] do
                  a = muzik |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              pk =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PK"
                end)

              pk =
                if pk != [] do
                  a = pk |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              pj =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PJ"
                end)

              pj =
                if pj != [] do
                  a = pj |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              seni =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "SENI"
                end)

              seni =
                if seni != [] do
                  a = seni |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              klk =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "KLK"
                end)

              klk =
                if klk != [] do
                  a = klk |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              dsv =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "DSV"
                end)

              dsv =
                if dsv != [] do
                  a = dsv |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              psv =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "PSV"
                end)

              psv =
                if psv != [] do
                  a = psv |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1g
                  end
                else
                  ""
                end

              total =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "TOTAL"
                end)

              total =
                if total != [] do
                  a = total |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m |> String.split("/") |> hd
                  end
                else
                  ""
                end

              averg =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "AVERG"
                end)

              averg =
                if averg != [] do
                  a = averg |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    a.s1m |> String.split("/") |> hd
                  end
                else
                  ""
                end

              crank =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "CRANK"
                end)

              crank =
                if crank != [] do
                  a = crank |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    if a.s1m != nil do
                      a.s1m |> String.split("/") |> hd |> String.to_integer()
                    else
                      ""
                    end
                  end
                else
                  ""
                end

              srank =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id) and x.subject == "SRANK"
                end)

              srank =
                if srank != [] do
                  a = srank |> hd

                  if a.s1g == "TH" do
                    "TH"
                  else
                    if a.s1m != nil do
                      a.s1m |> String.split("/") |> hd |> String.to_integer()
                    else
                      ""
                    end
                  end
                else
                  ""
                end

              all_pass =
                marks
                |> Enum.filter(fn x ->
                  x.stuid == Integer.to_string(sd.student_id)
                end)

              all_pass =
                if all_pass != [] do
                  got_fail =
                    all_pass
                    |> Enum.filter(fn x ->
                      x.subject != "AGM" and x.subject != "PM"
                    end)
                    |> Enum.any?(fn x -> x.s1g == "E" end)

                  got_th =
                    all_pass
                    |> Enum.filter(fn x ->
                      x.subject != "AGM" and x.subject != "PM"
                    end)
                    |> Enum.any?(fn x -> x.s1g == "TH" end)

                  a =
                    cond do
                      got_th != true && got_fail != true ->
                        true

                      got_th ->
                        false

                      got_fail ->
                        false

                      true ->
                        false
                    end
                end

              aa =
                if conn.private.plug_session["institution_id"] != 9 do
                  psv
                else
                  dsv
                end

              %{
                a: name,
                b: bcl,
                c: bct,
                d: bcf,
                e: bml,
                f: bmt,
                g: bmf,
                h: bil,
                i: bit,
                j: bif,
                k: math,
                l: sains,
                m: moral,
                n: agama,
                o: sejarah,
                p: rbt,
                q: tmk,
                r: aa,
                s: pj,
                sa: pk,
                sb: muzik,
                t: klk,
                u: total,
                v: averg,
                w: crank,
                x: srank,
                y: all_pass
              }
            end

        "2" ->
          "s2m"

        "3" ->
          "s3m"

        "4" ->
          "s4m"
      end

    if type == "PDF(Rank)" do
      institution =
        Repo.get_by(School.Settings.Institution, %{
          id: conn.private.plug_session["institution_id"]
        })

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          "exam_result_standard.html",
          level: standard,
          atten: atten,
          fail: fail,
          pass: pass,
          exam_name: exam_mast.name,
          institution: institution,
          examdata: examdata |> Enum.sort_by(fn x -> x.x end)
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
            "utf-8",
            "--orientation",
            "Landscape"
          ],
          delete_temporary: true
        )

      conn
      |> put_resp_header("Content-Type", "application/pdf")
      |> resp(200, pdf_binary)
    else
      if type == "PDF(Student)" do
        institution =
          Repo.get_by(School.Settings.Institution, %{
            id: conn.private.plug_session["institution_id"]
          })

        html =
          Phoenix.View.render_to_string(
            SchoolWeb.PdfView,
            "exam_result_standard.html",
            level: standard,
            atten: atten,
            fail: fail,
            pass: pass,
            exam_name: exam_mast.name,
            institution: institution,
            examdata: examdata |> Enum.sort_by(fn x -> x.a end)
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
              "utf-8",
              "--orientation",
              "Landscape"
            ],
            delete_temporary: true
          )

        conn
        |> put_resp_header("Content-Type", "application/pdf")
        |> resp(200, pdf_binary)
      else
        gg =
          if conn.private.plug_session["institution_id"] != 9 do
            "PSV"
          else
            "DSV"
          end

        csv_content = [
          "Name",
          "BCL",
          "BCF",
          "BCT",
          "BML",
          "BMF",
          "BMT",
          "BIL",
          "BIF",
          "BIT",
          "MAT",
          "SN",
          "PM",
          "AGM",
          "SEJ",
          "RBT",
          "TMK",
          gg,
          "PJ",
          "PK",
          "MZ",
          "KLK",
          "总分",
          "平均",
          "KDK",
          "KDD"
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
          for item <- examdata |> Enum.sort_by(fn x -> x.k end) |> Enum.with_index() do
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

        data =
          if data == [] do
            [{"A2", "No Data"}]
          else
            data
          end

        final = header ++ data

        sheet = Sheet.with_name("ExamResultStandard")

        total = Enum.reduce(final, sheet, fn x, sheet -> sheet_cell_insert(sheet, x) end)

        total =
          total
          |> Sheet.set_col_width("A", 50.0)

        page = %Workbook{sheets: [total]}

        image_path = Application.app_dir(:school, "priv/static/images")
        path = File.cwd!() <> "/media"
        content = page |> Elixlsx.write_to(image_path <> "/ExamResultStandard.xlsx")

        file = File.read!(image_path <> "/ExamResultStandard.xlsx")

        conn
        |> put_resp_content_type("text/xlsx")
        |> put_resp_header(
          "content-disposition",
          "attachment; filename=\"ExamResultStandard-#{standard.name}.xlsx\""
        )
        |> send_resp(200, file)
      end
    end
  end
end
