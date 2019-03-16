defmodule SchoolWeb.PdfController do
  use SchoolWeb, :controller
  use Task

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

  def report_card_temp(conn, params) do
    class_name = params["class"]
    semester_id = params["semester"]

    class_info =
      Repo.get_by(School.Affairs.Class,
        name: class_name,
        institution_id: conn.private.plug_session["institution_id"]
      )

    semester = Repo.get_by(School.Affairs.Semester, id: semester_id)

    institute =
      Repo.get_by(School.Settings.Institution, id: conn.private.plug_session["institution_id"])

    subject =
      Repo.all(
        from(s in School.Affairs.Subject,
          where: s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    student_class =
      Repo.all(
        from(s in School.Affairs.Student,
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
        from(s in School.Affairs.ExamMaster,
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
                  standard_id: sc.level_id
                }
              )
            )
            |> Enum.sort()

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

                  a.mark |> Integer.to_string()
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
                    for grade <- grades do
                      if a.mark >= grade.min and a.mark <= grade.max do
                        grade.name
                      end
                    end
                    |> Enum.filter(fn x -> x != nil end)
                    |> hd
                end

              {no + 1, fit}
            end

          finish =
            if all != [] do
              all = all |> hd

              count = mark |> Enum.count()

              {s1m, s2m, s3m, s1g, s2g, s3g} =
                if count == 1 do
                  s1m = mark |> Enum.fetch!(0) |> elem(1)
                  s2m = ""
                  s3m = ""
                  s1g = grade |> Enum.fetch!(0) |> elem(1)
                  s2g = ""
                  s3g = ""

                  {s1m, s2m, s3m, s1g, s2g, s3g}
                else
                  if count == 2 do
                    s1m = mark |> Enum.fetch!(0) |> elem(1)
                    s2m = mark |> Enum.fetch!(1) |> elem(1)
                    s3m = ""
                    s1g = grade |> Enum.fetch!(0) |> elem(1)
                    s2g = grade |> Enum.fetch!(1) |> elem(1)
                    s3g = ""
                    {s1m, s2m, s3m, s1g, s2g, s3g}
                  else
                    if count == 3 do
                      s1m = mark |> Enum.fetch!(0) |> elem(1)
                      s2m = mark |> Enum.fetch!(1) |> elem(1)
                      s3m = mark |> Enum.fetch!(2) |> elem(1)
                      s1g = grade |> Enum.fetch!(0) |> elem(1)
                      s2g = grade |> Enum.fetch!(1) |> elem(1)
                      s3g = grade |> Enum.fetch!(2) |> elem(1)
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
              where: c.name == ^class_name and sc.semester_id == ^semester_id,
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
                    sum = items |> Enum.map(fn x -> x.mark end) |> Enum.sum()

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
                        total_mark: sum,
                        standard_id: item.standard_id
                      }
                    end
                  end
                  |> Enum.sort_by(fn x -> x.total_mark end)
                  |> Enum.reverse()
                  |> Enum.with_index()
              end

            end_fit =
              for item <- drg do
                if item != [] do
                  no = item |> elem(1)

                  item = item |> elem(0)

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
                    rank: no + 1,
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

                a.rank |> Integer.to_string()
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
              where: e.level_id == ^class_info.level_id and sc.semester_id == ^semester_id,
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
                    sum = items |> Enum.map(fn x -> x.mark end) |> Enum.sum()

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
                        total_mark: sum,
                        standard_id: item.standard_id
                      }
                    end
                  end
                  |> Enum.sort_by(fn x -> x.total_mark end)
                  |> Enum.reverse()
                  |> Enum.with_index()
              end

            end_fit =
              for item <- drg do
                if item != [] do
                  no = item |> elem(1)

                  item = item |> elem(0)

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
                    rank: no + 1,
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

                a.rank |> Integer.to_string()
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
                a = fit |> Enum.map(fn x -> x.mark end) |> Enum.sum() |> Integer.to_string()
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
                a = fit |> Enum.map(fn x -> x.mark end) |> Enum.sum()

                per = fit |> Enum.map(fn x -> x.mark end) |> Enum.count()
                total_per = per * 100

                total_average = (a / total_per * 100) |> Float.round(2) |> Float.to_string()
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

    result = result ++ class_rank ++ standard_rank ++ total_markfinish ++ total_purata

    exist =
      Repo.all(
        from(s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem)
        )
      )

    if exist != [] do
      Repo.delete_all(
        from(s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem)
        )
      )

      for item <- result do
        case Affairs.create_mark_sheet_temp(item) do
          {:ok, mark_sheet_temp} ->
            conn
            |> put_flash(:info, "Mark sheet temp created successfully.")
            |> redirect(to: "/list_report")

          {:error, %Ecto.Changeset{} = changeset} ->
            IEx.pry()
        end
      end
    else
      for item <- result do
        case Affairs.create_mark_sheet_temp(item) do
          {:ok, mark_sheet_temp} ->
            conn
            |> put_flash(:info, "Mark sheet temp created successfully.")
            |> redirect(to: "/list_report")

          {:error, %Ecto.Changeset{} = changeset} ->
            IEx.pry()
        end
      end
    end

    conn
    |> put_flash(:info, "Mark sheet generated")
    |> redirect(to: mark_sheet_temp_path(conn, :index))
  end

  def report_card_all(conn, params) do
    class_name = params["class"]
    semester_id = params["semester"]

    semester = Repo.get_by(School.Affairs.Semester, id: semester_id)

    class_info =
      Repo.get_by(School.Affairs.Class,
        name: class_name,
        institution_id: conn.private.plug_session["institution_id"]
      )

    list_exam =
      Repo.all(from(s in School.Affairs.ExamMaster, where: s.level_id == ^class_info.level_id))

    data =
      Repo.all(
        from(s in School.Affairs.MarkSheetTemp,
          where:
            s.institution_id == ^conn.private.plug_session["institution_id"] and
              s.class == ^class_name and s.year == ^Integer.to_string(semester.year) and
              s.semester == ^Integer.to_string(semester.sem)
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
            "report_cards.html"
        end

      html =
        Phoenix.View.render_to_string(
          SchoolWeb.PdfView,
          school,
          a: data,
          list_exam: list_exam,
          institute: institute
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

    # all =
    #   Repo.all(
    #     from(
    #       s in School.Affairs.HeadCount,
    #       left_join: p in School.Affairs.Student,
    #       on: s.student_id == p.id,
    #       where:
    #         s.class_id == ^class_id and s.subject_id == ^subject_id and
    #           s.institution_id == ^conn.private.plug_session["institution_id"] and
    #           p.institution_id == ^conn.private.plug_session["institution_id"] and
    #           s.semester_id == ^conn.private.plug_session["semester_id"],
    #       select: %{
    #         student_name: p.name,
    #         chinese_name: p.chinese_name,
    #         sex: p.sex,
    #         class_id: s.class_id,
    #         subject_id: s.subject_id,
    #         student_id: s.student_id,
    #         mark: s.targer_mark
    #       }
    #     )
    #   )

    # a =
    #   Repo.all(
    #     from(
    #       p in School.Affairs.Exam,
    #       left_join: m in School.Affairs.ExamMaster,
    #       on: m.id == p.exam_master_id,
    #       left_join: h in School.Affairs.ExamMark,
    #       on: h.exam_id == p.id,
    #       left_join: k in School.Affairs.HeadCount,
    #       on: k.student_id == h.student_id,
    #       left_join: q in School.Affairs.Level,
    #       on: q.id == m.level_id,
    #       left_join: g in School.Affairs.Subject,
    #       on: g.id == p.subject_id,
    #       left_join: l in School.Affairs.Student,
    #       on: k.student_id == l.id,
    #       left_join: s in School.Affairs.Class,
    #       on: s.level_id == m.level_id,
    #       where:
    #         m.semester_id == ^conn.private.plug_session["semester_id"] and s.id == ^class_id and
    #           g.id == ^subject_id and h.subject_id == ^subject_id and h.class_id == ^class_id and
    #           m.semester_id == ^conn.private.plug_session["semester_id"] and
    #           s.institution_id == ^conn.private.plug_session["institution_id"] and
    #           g.institution_id == ^conn.private.plug_session["institution_id"] and
    #           q.institution_id == ^conn.private.plug_session["institution_id"] and
    #           m.institution_id == ^conn.private.plug_session["institution_id"],
    #       select: %{
    #         id: p.id,
    #         student_id: h.student_id,
    #         mark: h.mark,
    #         h_count_mark: k.targer_mark,
    #         c_id: s.id,
    #         s_id: g.id,
    #         class: s.name,
    #         exam: m.name,
    #         sex: l.sex,
    #         student_name: l.name,
    #         chinese_name: l.chinese_name,
    #         subject: g.description
    #       }
    #     )
    #   )

    # f =
    #   Repo.all(
    #     from(
    #       p in School.Affairs.Exam,
    #       left_join: m in School.Affairs.ExamMaster,
    #       on: m.id == p.exam_master_id,
    #       left_join: h in School.Affairs.ExamMark,
    #       on: h.exam_id == p.id,
    #       left_join: k in School.Affairs.HeadCount,
    #       on: k.student_id == h.student_id,
    #       left_join: q in School.Affairs.Level,
    #       on: q.id == m.level_id,
    #       left_join: g in School.Affairs.Subject,
    #       on: g.id == p.subject_id,
    #       left_join: l in School.Affairs.Student,
    #       on: k.student_id == l.id,
    #       left_join: s in School.Affairs.Class,
    #       on: s.level_id == m.level_id,
    #       where:
    #         m.semester_id == ^conn.private.plug_session["semester_id"] and s.id == ^class_id and
    #           g.id == ^subject_id and h.subject_id == ^subject_id and h.class_id == ^class_id and
    #           m.semester_id == ^conn.private.plug_session["semester_id"] and
    #           s.institution_id == ^conn.private.plug_session["institution_id"] and
    #           g.institution_id == ^conn.private.plug_session["institution_id"] and
    #           q.institution_id == ^conn.private.plug_session["institution_id"] and
    #           m.institution_id == ^conn.private.plug_session["institution_id"],
    #       select: %{
    #         id: p.id,
    #         student_id: h.student_id,
    #         mark: h.mark,
    #         h_count_mark: k.targer_mark,
    #         c_id: s.id,
    #         s_id: g.id,
    #         class: s.name,
    #         exam: m.name,
    #         sex: l.sex,
    #         student_name: l.name,
    #         chinese_name: l.chinese_name,
    #         subject: g.description
    #       }
    #     )
    #   )
    #   |> Enum.group_by(fn x -> x.exam end)
    #   |> Map.keys()
    #   |> Enum.sort()

    # if all == [] do
    #   conn
    #   |> put_flash(:info, "Data Is Empty, Please Choose Other Selection")
    #   |> redirect(to: head_count_path(conn, :headcount_report))
    # else

    # html =
    #   Phoenix.View.render_to_string(
    #     SchoolWeb.PdfView,
    #     "head_count_listing.html",
    #     class: class,
    #     subject: subject_info,
    #     all: all,
    #     institution: school,
    #     a: a,
    #     f: f
    #   )

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

  def user_login_report(conn, params) do
    users =
      Repo.all(
        from(s in User,
          left_join: g in Settings.UserAccess,
          on: s.id == g.user_id,
          where: g.institution_id == ^conn.private.plug_session["institution_id"]
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
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.class_id == ^class_id and k.id == ^exam_id and
              k.institution_id == ^conn.private.plug_session["institution_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
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
                  student_mark: -1,
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

        datas = item |> elem(1)

        for data <- datas do
          student_mark = data.student_mark

          grades =
            Repo.all(
              from(
                g in School.Affairs.ExamGrade,
                where:
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.exam_master_id == ^exam.id
              )
            )

          for grade <- grades do
            if student_mark >= grade.min and student_mark <= grade.max do
              %{
                student_id: data.student_id,
                student_name: data.student_name,
                grade: grade.name,
                gpa: grade.gpa,
                subject_code: subject_code,
                student_mark: student_mark,
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

    z =
      for new <- news do
        total =
          new
          |> elem(1)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.sum()

        per =
          new
          |> elem(1)
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

        total_gpa = new |> elem(1) |> Enum.map(fn x -> Decimal.to_float(x.gpa) end) |> Enum.sum()

        cgpa = (total_gpa / per) |> Float.round(2)
        total_average = (total / total_per * 100) |> Float.round(2)

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
        exam_id: params["exam_id"]
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
                  student_mark: -1,
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

        for data <- datas do
          student_mark = data.student_mark

          grades =
            Repo.all(
              from(
                g in School.Affairs.ExamGrade,
                where:
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.exam_master_id == ^exam_id.id
              )
            )

          for grade <- grades do
            if student_mark >= grade.min and student_mark <= grade.max do
              %{
                student_id: data.student_id,
                student_name: data.student_name,
                grade: grade.name,
                gpa: grade.gpa,
                subject_code: subject_code,
                student_mark: student_mark,
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

    z =
      for new <- news do
        total =
          new
          |> elem(1)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.sum()

        per =
          new
          |> elem(1)
          |> Enum.map(fn x -> x.student_mark end)
          |> Enum.filter(fn x -> x != -1 end)
          |> Enum.count()

        total_per = per * 100

        total_average = (total / total_per * 100) |> Float.round(2)

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

        total_gpa = new |> elem(1) |> Enum.map(fn x -> Decimal.to_float(x.gpa) end) |> Enum.sum()

        cgpa = (total_gpa / per) |> Float.round(2)

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
        level: level
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

  def student_class_listing(conn, params) do
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
        from(s in School.Affairs.AssessmentMark,
          where:
            s.institution_id == ^inst_id and s.class_id == ^params["class"] and
              s.semester_id == ^params["semester"]
        )
      )
      |> Enum.group_by(fn x -> x.student_id end)

    semester =
      Repo.get_by(School.Affairs.Semester,
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
        from(s in School.Affairs.Teacher,
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
    class_id = params["class_id"]
    exam_id = params["exam_id"]

    class =
      Repo.get_by(School.Affairs.Class, %{
        id: class_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    exam =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          left_join: p in School.Affairs.Subject,
          on: s.subject_id == p.id,
          left_join: d in School.Affairs.Exam,
          on: s.exam_id == d.id,
          left_join: t in School.Affairs.ExamMaster,
          on: d.exam_master_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          where:
            s.class_id == ^class_id and d.exam_master_id == ^exam.id and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              t.institution_id == ^conn.private.plug_session["institution_id"] and
              r.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            class_name: r.name,
            subject_code: p.code,
            exam_name: t.name,
            student_id: s.student_id,
            mark: s.mark
          }
        )
      )

    all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        datas = item |> elem(1)

        for data <- datas do
          student_mark = data.mark

          grades =
            Repo.all(
              from(
                g in School.Affairs.ExamGrade,
                where:
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.exam_master_id == ^exam.id
              )
            )

          for grade <- grades do
            if student_mark >= grade.min and student_mark <= grade.max do
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

    group = mark1 |> Enum.group_by(fn x -> x.subject_code end)

    group_subject =
      for item <- group do
        subject = item |> elem(0)

        total_student = item |> elem(1) |> Enum.count()
        a = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        lulus = a + b + c + d
        fail = e + f + g

        %{
          subject: subject,
          total_student: total_student,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          f: f,
          g: g,
          lulus: lulus,
          tak_lulus: fail
        }
      end

    a = group_subject |> Enum.map(fn x -> x.a end) |> Enum.sum()
    b = group_subject |> Enum.map(fn x -> x.b end) |> Enum.sum()
    c = group_subject |> Enum.map(fn x -> x.c end) |> Enum.sum()
    d = group_subject |> Enum.map(fn x -> x.d end) |> Enum.sum()
    e = group_subject |> Enum.map(fn x -> x.e end) |> Enum.sum()
    f = group_subject |> Enum.map(fn x -> x.f end) |> Enum.sum()
    g = group_subject |> Enum.map(fn x -> x.g end) |> Enum.sum()
    lulus = group_subject |> Enum.map(fn x -> x.lulus end) |> Enum.sum()
    tak_lulus = group_subject |> Enum.map(fn x -> x.tak_lulus end) |> Enum.sum()
    total = group_subject |> Enum.map(fn x -> x.total_student end) |> Enum.sum()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "exam_result_analysis_by_class.html",
        a: a,
        b: b,
        c: c,
        d: d,
        e: e,
        f: f,
        g: g,
        lulus: lulus,
        tak_lulus: tak_lulus,
        total: total,
        group_subject: group_subject,
        exam: exam,
        class: class
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

  def exam_result_analysis_class_standard(conn, params) do
    standard_id = params["standard_id"]
    exam_id = params["exam_id"]

    standard =
      Repo.get_by(School.Affairs.Level, %{
        id: standard_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    exam =
      Repo.get_by(School.Affairs.ExamMaster, %{
        id: exam_id,
        institution_id: conn.private.plug_session["institution_id"]
      })

    all =
      Repo.all(
        from(
          s in School.Affairs.ExamMark,
          left_join: p in School.Affairs.Subject,
          on: s.subject_id == p.id,
          left_join: g in School.Affairs.Exam,
          on: s.exam_id == g.id,
          left_join: t in School.Affairs.ExamMaster,
          on: g.exam_master_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          where:
            r.level_id == ^standard.id and g.exam_master_id == ^exam.id and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              t.institution_id == ^conn.private.plug_session["institution_id"] and
              r.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            class_name: r.name,
            subject_code: p.code,
            exam_name: t.name,
            student_id: s.student_id,
            mark: s.mark
          }
        )
      )

    all_mark = all |> Enum.group_by(fn x -> x.subject_code end)

    mark1 =
      for item <- all_mark do
        subject_code = item |> elem(0)

        datas = item |> elem(1)

        for data <- datas do
          student_mark = data.mark

          grades =
            Repo.all(
              from(
                g in School.Affairs.ExamGrade,
                where:
                  g.institution_id == ^conn.private.plug_session["institution_id"] and
                    g.exam_master_id == ^exam.id
              )
            )

          for grade <- grades do
            if student_mark >= grade.min and student_mark <= grade.max do
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

    group = mark1 |> Enum.group_by(fn x -> x.subject_code end)

    group_subject =
      for item <- group do
        subject = item |> elem(0)

        total_student = item |> elem(1) |> Enum.count()
        a = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "A" end)
        b = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "B" end)
        c = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "C" end)
        d = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "D" end)
        e = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "E" end)
        f = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "F" end)
        g = item |> elem(1) |> Enum.map(fn x -> x.grade end) |> Enum.count(fn x -> x == "G" end)

        lulus = a + b + c + d
        fail = e + f + g

        %{
          subject: subject,
          total_student: total_student,
          a: a,
          b: b,
          c: c,
          d: d,
          e: e,
          f: f,
          g: g,
          lulus: lulus,
          tak_lulus: fail
        }
      end

    a = group_subject |> Enum.map(fn x -> x.a end) |> Enum.sum()
    b = group_subject |> Enum.map(fn x -> x.b end) |> Enum.sum()
    c = group_subject |> Enum.map(fn x -> x.c end) |> Enum.sum()
    d = group_subject |> Enum.map(fn x -> x.d end) |> Enum.sum()
    e = group_subject |> Enum.map(fn x -> x.e end) |> Enum.sum()
    f = group_subject |> Enum.map(fn x -> x.f end) |> Enum.sum()
    g = group_subject |> Enum.map(fn x -> x.g end) |> Enum.sum()
    lulus = group_subject |> Enum.map(fn x -> x.lulus end) |> Enum.sum()
    tak_lulus = group_subject |> Enum.map(fn x -> x.tak_lulus end) |> Enum.sum()
    total = group_subject |> Enum.map(fn x -> x.total_student end) |> Enum.sum()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "result_analysis_by_standard.html",
        a: a,
        b: b,
        c: c,
        d: d,
        e: e,
        f: f,
        g: g,
        lulus: lulus,
        tak_lulus: tak_lulus,
        total: total,
        group_subject: group_subject,
        exam: exam,
        standard: standard,
        standard_id: standard_id,
        exam_id: exam_id
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

  def student_list_by_co(conn, params) do
    cocurriculum = params["cocurriculum_id"]
    co_level = params["standard_id"]
    co_semester = params["semester_id"]
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
            mark: s.mark
          }
        )
      )

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
            level_id: sc.level_id
          }
        )
      )

    students =
      for student <- students1 do
        if Enum.any?(sc, fn x -> x.student_id == student.student_id end) do
          b = sc |> Enum.filter(fn x -> x.student_id == student.student_id end) |> hd()

          student = Map.put(student, :class_name, b.class)
          student = Map.put(student, :level_id, b.level_id)
          student
        else
          student = Map.put(student, :class_name, "no class assigned")
          student = Map.put(student, :level_id, 0)
          student
        end
      end

    students =
      if co_level != "Choose a level" do
        students |> Enum.filter(fn x -> x.level_id == String.to_integer(co_level) end)
      else
        students
      end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "student_listing_by_cocurriculum.html",
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
end
