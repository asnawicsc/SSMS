defmodule SchoolWeb.PdfController do
  use SchoolWeb, :controller
  use Task

  require IEx

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
          where: c.class_id == ^params["class_id"] and c.semester_id == ^semester.id,
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
        if params["class_id"] != "all_class" do
          student = Map.put(student, :class, class.name)
        else
          student_class = Repo.get_by(StudentClass, sudent_id: student.id)
          class = Repo.get(Class, student_class.class_id)
        end

        height_final =
          if student.height != nil do
            heights = String.split(student.height, ",")

            height_d =
              for height <- heights do
                l_id =
                  String.split(height, "-") |> List.to_tuple() |> elem(0) |> String.to_integer()

                if l_id == class.level_id do
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

        if student.weight != nil do
          weights = String.split(student.weight, ",")

          weight_d =
            for weight <- weights do
              l_id =
                String.split(weight, "-") |> List.to_tuple() |> elem(0) |> String.to_integer()

              if l_id == class.level_id do
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
    school = Repo.get(Institution, User.institution_id(conn))

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
        where: em.id == ^exam_mid and c.name == ^class_name,
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

  def class_ranking(conn, params) do
    class_id = params["class_id"] |> String.to_integer()
    exam_id = params["exam_id"] |> String.to_integer()
    class = Repo.get_by(School.Affairs.Class, id: class_id)

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where: e.class_id == ^class_id and e.exam_id == ^exam_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
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
          where: e.exam_master_id == ^exam_id,
          select: %{
            subject_code: p.code,
            exam_name: k.name
          }
        )
      )

    all =
      for item <- exam_standard do
        exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd
        student_list = exam_mark |> Enum.map(fn x -> x.student_name end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student = Repo.get_by(School.Affairs.Student, %{name: item})
            s_mark = all_mark |> Enum.filter(fn x -> x.student_name == item end)

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

          grades = Repo.all(from(g in School.Affairs.Grade))

          for grade <- grades do
            if student_mark >= grade.mix and student_mark <= grade.max do
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

    news = mark1 |> Enum.group_by(fn x -> x.student_name end)

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
          name: new |> elem(0),
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

    exam_id = Repo.get_by(School.Affairs.ExamMaster, %{id: exam_id, level_id: level_id})

    level = Repo.get_by(School.Affairs.Level, %{id: level_id})

    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where: e.exam_id == ^exam_id.id and k.level_id == ^level_id,
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
          where: e.exam_master_id == ^exam_id.id,
          select: %{
            subject_code: p.code,
            exam_name: k.name
          }
        )
      )

    all =
      for item <- exam_standard do
        exam_name = exam_mark |> Enum.map(fn x -> x.exam_name end) |> Enum.uniq() |> hd
        student_list = exam_mark |> Enum.map(fn x -> x.student_name end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student = Repo.get_by(School.Affairs.Student, %{name: item})
            student_class = Repo.get_by(School.Affairs.StudentClass, %{sudent_id: student.id})
            s_mark = all_mark |> Enum.filter(fn x -> x.student_name == item end)

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

          grades = Repo.all(from(g in School.Affairs.Grade))

          for grade <- grades do
            if student_mark >= grade.mix and student_mark <= grade.max do
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

    news = mark1 |> Enum.group_by(fn x -> x.student_name end)

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
          name: new |> elem(0),
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
end
