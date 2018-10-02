defmodule SchoolWeb.PdfController do
  use SchoolWeb, :controller
  use Task

  require IEx

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
                c.institution_id == ^conn.private.plug_session["institution_id"],
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
            student_class = Repo.get_by(StudentClass, sudent_id: student.id)
            class = Repo.get(Class, student_class.class_id)
            {class, student_class}
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

        weight =
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
              j.institution_id == ^conn.private.plug_session["institution_id"],
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
              sm.institution_id == ^conn.private.plug_session["institution_id"],
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

    class =
      Repo.get_by(
        School.Affairs.Class,
        id: params["class_id"],
        institution_id: conn.private.plug_session["institution_id"]
      )

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
          where:
            e.class_id == ^class_id and e.exam_id == ^exam_id and
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
        student_list = exam_mark |> Enum.map(fn x -> x.student_name end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student =
              Repo.get_by(School.Affairs.Student, %{
                name: item,
                institution_id: conn.private.plug_session["institution_id"]
              })

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

          grades =
            Repo.all(
              from(
                g in School.Affairs.Grade,
                where: g.institution_id == ^conn.private.plug_session["institution_id"]
              )
            )

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
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            e.exam_id == ^exam_id.id and k.level_id == ^level_id and
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
        student_list = exam_mark |> Enum.map(fn x -> x.student_name end) |> Enum.uniq()
        all_mark = exam_mark |> Enum.filter(fn x -> x.subject_code == item.subject_code end)

        subject_code = item.subject_code

        all =
          for item <- student_list do
            student =
              Repo.get_by(School.Affairs.Student, %{
                name: item,
                institution_id: conn.private.plug_session["institution_id"]
              })

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

  def student_class_listing(conn, params) do
    class_id = params["class_id"]

    all =
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
              r.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            id: s.sudent_id,
            chinese_name: r.chinese_name,
            name: r.name,
            sex: r.sex,
            dob: r.dob,
            pob: r.pob,
            b_cert: r.b_cert,
            religion: r.religion,
            race: r.race
          }
        )
      )
      |> Enum.with_index()

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.PdfView,
        "student_class_listing.html",
        all: all
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

  def teacher_listing(conn, params) do
    inst_id = conn.private.plug_session["institution_id"]

    institution = Repo.get_by(School.Settings.Institution, id: inst_id)

    teacher = Affairs.list_teacher() |> Enum.with_index()

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
          left_join: t in School.Affairs.ExamMaster,
          on: s.exam_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          where:
            s.class_id == ^class_id and s.exam_id == ^exam.id and
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
            Repo.all(from(g in School.Affairs.Grade))
            |> Enum.filter(fn x ->
              x.institution_id == conn.private.plug_session["institution_id"]
            end)

          for grade <- grades do
            if student_mark >= grade.mix and student_mark <= grade.max do
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
          left_join: t in School.Affairs.ExamMaster,
          on: s.exam_id == t.id,
          left_join: r in School.Affairs.Class,
          on: r.id == s.class_id,
          left_join: d in School.Affairs.Level,
          on: r.level_id == d.id,
          where:
            r.level_id == ^standard.id and s.exam_id == ^exam.id and
              p.institution_id == ^conn.private.plug_session["institution_id"] and
              t.institution_id == ^conn.private.plug_session["institution_id"] and
              r.institution_id == ^conn.private.plug_session["institution_id"] and
              d.institution_id == ^conn.private.plug_session["institution_id"],
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
            Repo.all(from(g in School.Affairs.Grade))
            |> Enum.filter(fn x ->
              x.institution_id == conn.private.plug_session["institution_id"]
            end)

          for grade <- grades do
            if student_mark >= grade.mix and student_mark <= grade.max do
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
    co_year = params["year"]
    co_level = params["standard_id"]
    co_semester = params["semester_id"]

    students =
      Repo.all(
        from(
          s in School.Affairs.StudentCocurriculum,
          left_join: a in School.Affairs.Student,
          on: s.student_id == a.id,
          left_join: j in School.Affairs.StudentClass,
          on: s.student_id == j.sudent_id,
          left_join: p in School.Affairs.CoCurriculum,
          on: s.cocurriculum_id == p.id,
          left_join: c in School.Affairs.Class,
          on: j.class_id == c.id,
          where:
            s.cocurriculum_id == ^cocurriculum and s.year == ^co_year and
              s.semester_id == ^co_semester and s.standard_id == ^co_level and
              a.institution_id == ^conn.private.plug_session["institution_id"] and
              c.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            id: p.id,
            student_id: s.student_id,
            chinese_name: a.chinese_name,
            name: a.name,
            class_name: c.name,
            mark: s.mark
          }
        )
      )

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
          "Landscape"
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
