defmodule SchoolWeb.StudentController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Student
  require IEx

  def index(conn, _params) do
    students =
      Repo.all(
        from(
          s in Student,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
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

        if cur_class.next_class != nil do
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
    semester = Repo.get(Semester, params["semester_id"])

    students =
      if user.role == "Teacher" do
        teacher = Repo.get_by(Teacher, email: user.email)

        students =
          Repo.all(
            from(
              s in Student,
              left_join: sc in StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in Class,
              on: c.id == sc.class_id,
              left_join: t in Teacher,
              on: t.id == c.teacher_id,
              where: t.id == ^teacher.id and sc.semester_id == ^semester.id,
              select: %{
                name: s.name,
                chinese_name: s.chinese_name,
                height: s.height,
                weight: s.weight,
                id: s.id
              }
            )
          )

        students
      else
        students =
          Repo.all(
            from(
              s in Student,
              left_join: sc in StudentClass,
              on: sc.sudent_id == s.id,
              left_join: c in Class,
              on: c.id == sc.class_id,
              left_join: t in Teacher,
              on: t.id == c.teacher_id,
              where: sc.semester_id == ^semester.id,
              select: %{
                name: s.name,
                chinese_name: s.chinese_name,
                height: s.height,
                weight: s.weight,
                id: s.id
              }
            )
          )

        students
      end

    students =
      for student <- students do
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
      end

    render(conn, "height_weight_semester.html", students: students, semester_id: semester.id)
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
    |> redirect(to: "/height_weight/#{params["semester_id"]}")
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
                        c.institution_id == ^conn.private.plug_session["institution_id"],
                    order_by: [asc: s.name],
                    select: %{
                      id: s.id,
                      name: s.name,
                      chinese_name: s.chinese_name,
                      class: cl.name,
                      b_cert: s.b_cert
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
                  cl.institution_id == ^conn.private.plug_session["institution_id"],
              order_by: [asc: s.name],
              select: %{
                id: s.id,
                name: s.name,
                chinese_name: s.chinese_name,
                class: cl.name,
                b_cert: s.b_cert
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
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          order_by: [asc: s.name]
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
              s.institution_id == ^conn.private.plug_session["institution_id"],
          order_by: [asc: s.name],
          select: %{
            id: s.id,
            name: s.name,
            chinese_name: s.chinese_name
          }
        )
      )

    student_class = Repo.all(from(s in StudentClass, where: s.class_id == ^params["class_id"]))
    level_id = hd(student_class).level_id
    level = Repo.all(from(l in Level, where: l.id == ^level_id))

    render(conn, "height_weight.html", students: students, levels: level)
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

    conn
    |> put_flash(:info, "Student Class created successfully.")
    |> redirect(to: student_path(conn, :index))
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

    case Affairs.create_student(student_params) do
      {:ok, student} ->
        conn
        |> put_flash(:info, "Student created successfully.")
        |> redirect(to: student_path(conn, :show, student))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
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

    case Affairs.update_student(student, params) do
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

  def delete(conn, %{"id" => id}) do
    student = Affairs.get_student!(id)
    {:ok, _student} = Affairs.delete_student(student)

    conn
    |> put_flash(:info, "Student deleted successfully.")
    |> redirect(to: student_path(conn, :index))
  end
end
