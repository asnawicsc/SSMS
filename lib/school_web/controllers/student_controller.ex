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

  def new(conn, _params) do
    changeset = Affairs.change_student(%Student{})

    render(conn, "new.html", changeset: changeset)
  end

  def upload_students(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    data = bin |> String.split("\t") |> Enum.chunk_every(24)
    headers = hd(data)
    contents = tl(data)

    student_params =
      for content <- contents do
        h = headers |> Enum.map(fn x -> Poison.decode!(x) end)

        c =
          for item <- content do
            case Poison.decode(item) do
              {:ok, i} ->
                i

              _ ->
                cond do
                  item == "" ->
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

        student_param = Map.put(student_param, "ic", student_param["ic_no"])

        if is_integer(student_param["postcode"]) do
          student_param =
            Map.put(student_param, "postcode", Integer.to_string(student_param["postcode"]))
        end

        if is_integer(student_param["student_no"]) do
          student_param =
            Map.put(student_param, "student_no", Integer.to_string(student_param["student_no"]))
        end

        if is_integer(student_param["ic"]) do
          student_param = Map.put(student_param, "ic", Integer.to_string(student_param["ic"]))
        end

        if is_integer(student_param["phone"]) do
          student_param =
            Map.put(student_param, "phone", Integer.to_string(student_param["phone"]))
        end

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

  def delete(conn, %{"id" => id}) do
    student = Affairs.get_student!(id)
    {:ok, _student} = Affairs.delete_student(student)

    conn
    |> put_flash(:info, "Student deleted successfully.")
    |> redirect(to: student_path(conn, :index))
  end
end
