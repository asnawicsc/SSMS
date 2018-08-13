defmodule SchoolWeb.TeacherController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Teacher
  require IEx

  def index(conn, _params) do
    teacher = Affairs.list_teacher()
    render(conn, "index.html", teacher: teacher)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher(%Teacher{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"teacher" => teacher_params}) do
    case Affairs.create_teacher(teacher_params) do
      {:ok, teacher} ->
        conn
        |> put_flash(:info, "Teacher created successfully.")
        |> redirect(to: teacher_path(conn, :show, teacher))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher = Affairs.get_teacher!(id)
    render(conn, "show.html", teacher: teacher)
  end

  def edit(conn, %{"id" => id}) do
    teacher = Affairs.get_teacher!(id)
    changeset = Affairs.change_teacher(teacher)
    render(conn, "edit.html", teacher: teacher, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher" => teacher_params}) do
    teacher = Repo.get_by(Teacher,code: id)

    case Affairs.update_teacher(teacher, teacher_params) do
      {:ok, teacher} ->
         url = teacher_path(conn, :index, focus: teacher.code)
        referer = conn.req_headers |> Enum.filter(fn x -> elem(x, 0) == "referer" end)

        if referer != [] do
          refer = hd(referer)
          url = refer |> elem(1) |> String.split("?") |> List.first()

          conn
          |> put_flash(:info, "#{teacher.name} updated successfully.")
          |> redirect(external: url <> "?focus=#{teacher.code}")
        else
          conn
          |> put_flash(:info, "#{teacher.name} updated successfully.")
          |> redirect(to: url)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher = Affairs.get_teacher!(id)
    {:ok, _teacher} = Affairs.delete_teacher(teacher)

    conn
    |> put_flash(:info, "Teacher deleted successfully.")
    |> redirect(to: teacher_path(conn, :index))
  end

   def upload_teachers(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    data = bin |> String.split("\n")|>Enum.map(fn x-> String.split(x,",") end)
    headers = hd(data)|>Enum.map(fn x-> String.trim(x," ")end)
    contents = tl(data)|>Enum.map(fn x-> String.trim(x," ")end)

    teachers_params =
      for content <- contents do


        h = headers |>Enum.map(fn x-> String.downcase(x) end)

        c =
          for item <- content do

              item=String.replace(item,"@@@",",") 
     
            case item do
              {:ok, i} ->
                i

              _ ->
                cond do
                  item == " " ->
                    "null"
                      item == "" ->
                    "null"
                     item == "  " ->
                    "null"

                  true ->
                    item

                    |> String.split("\"")
                    |> Enum.map(fn x -> String.replace(x, "\n", "") end)
                    |> List.last()

            
                end
            end
          end

        teachers_params = Enum.zip(h, c) |> Enum.into(%{})



        if is_integer(teachers_params["bcenrlno"]) do
           teachers_params =
           Map.put(teachers_params, "bcenrlno", Integer.to_string(teachers_params["bcenrlno"]))

        end

     

        cg = Teacher.changeset(%Teacher{}, teachers_params)

        case Repo.insert(cg) do
          {:ok, teacher} ->
            {:ok, teacher}

          {:error, cg} ->
            {:error, cg}
        end
      end

    conn
    |> put_flash(:info, "Teachers created successfully.")
    |> redirect(to: teacher_path(conn, :index))
  end
end
