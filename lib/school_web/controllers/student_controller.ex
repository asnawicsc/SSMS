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
                    where: s.id == ^student.student_id,
                    order_by: [asc: s.name],
                    select: %{
                      id: s.id,
                      name: s.name,
                      chinese_name: s.chinese_name,
                      class: cl.name
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
              where: s.institution_id == ^conn.private.plug_session["institution_id"],
              order_by: [asc: s.name],
              select: %{
                id: s.id,
                name: s.name,
                chinese_name: s.chinese_name,
                class: cl.name
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

    levels =
      Repo.all(Level)
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "height_weight.html", students: students, levels: levels)
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

  def upload_students(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)

    data = bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)
    contents = tl(data)
    {:ok, batch} = Settings.create_batch()

    student_params =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

        content = content |> Enum.map(fn x -> x end) |> Enum.filter(fn x -> x != "\"" end)

        c =
          for item <- content do
            item = String.replace(item, "@@@", ",")

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

        #   Map.put(student_param, "ic", Integer.to_string(student_param["ic_no"]))
        #  student_param =if is_integer(student_param["postcode"]) do

        #     Map.put(student_param, "postcode", Integer.to_string(student_param["postcode"]))
        # end

        #  student_param =if is_integer(student_param["student_no"]) do

        #     Map.put(student_param, "student_no", Integer.to_string(student_param["student_no"]))
        # end

        #  student_param = if is_integer(student_param["ic_no"]) do
        #  Map.put(student_param, "ic", Integer.to_string(student_param["ic_no"]))
        # end

        #  student_param =if is_integer(student_param["phone"]) do

        #     Map.put(student_param, "phone", Integer.to_string(student_param["phone"]))
        # end

        #    student_param =if is_integer(student_param["state"]) do

        #     Map.put(student_param, "state", Integer.to_string(student_param["state"]))
        # end

        cg = Student.changeset(%Student{}, student_param)

        case Repo.insert(cg) do
          {:ok, student} ->
            {:ok, student}

          {:error, cg} ->
            {:error, cg}
        end
      end

    conn
    |> put_flash(:info, "Student created successfully.")
    |> redirect(to: student_path(conn, :index))
  end

  def create(conn, %{"student" => student_params}) do
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
