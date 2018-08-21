defmodule SchoolWeb.SubjectController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.Subject

  def index(conn, _params) do
    subject = Affairs.list_subject()
    render(conn, "index.html", subject: subject)
  end

  def new(conn, _params) do
    changeset = Affairs.change_subject(%Subject{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"subject" => subject_params}) do
    case Affairs.create_subject(subject_params) do
      {:ok, subject} ->
        conn
        |> put_flash(:info, "Subject created successfully.")
        |> redirect(to: subject_path(conn, :show, subject))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    subject = Affairs.get_subject!(id)
    render(conn, "show.html", subject: subject)
  end

  def edit(conn, %{"id" => id}) do
    subject = Affairs.get_subject!(id)
    changeset = Affairs.change_subject(subject)
    render(conn, "edit.html", subject: subject, changeset: changeset)
  end

  def update(conn, %{"id" => id, "subject" => subject_params}) do
    subject = Repo.get_by(Subject,code: id)

    case Affairs.update_subject(subject, subject_params) do
      {:ok, subject} ->
         url = subject_path(conn, :index, focus: subject.code)
        referer = conn.req_headers |> Enum.filter(fn x -> elem(x, 0) == "referer" end)

        if referer != [] do
          refer = hd(referer)
          url = refer |> elem(1) |> String.split("?") |> List.first()

          conn
          |> put_flash(:info, "#{subject.description} updated successfully.")
          |> redirect(external: url <> "?focus=#{subject.code}")
        else
          conn
          |> put_flash(:info, "#{subject.description} updated successfully.")
          |> redirect(to: url)
        end

        {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", subject: subject, changeset: changeset)
    
    end

  end



  def delete(conn, %{"id" => id}) do
  
    subject = Affairs.get_subject!(id)
    {:ok, _subject} = Affairs.delete_subject(subject)

    conn
    |> put_flash(:info, "Subject deleted successfully.")
    |> redirect(to: subject_path(conn, :index))
  end

   def upload_subjects(conn, params) do
    bin = params["item"]["file"].path |> File.read() |> elem(1)
    data = bin |>String.split("\n")|>Enum.map(fn x-> String.split(x,",") end)
    headers = hd(data)|>Enum.map(fn x-> String.trim(x," ")end)
    contents = tl(data)
      

    subject_params =
      for content <- contents do

        h = headers |>Enum.map(fn x-> String.downcase(x) end)


        c =
          for item <- content do


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


        subject_params = Enum.zip(h, c) |> Enum.into(%{})


        if is_integer(subject_params["sysdef"]) do
          subject_params =
            Map.put(subject_params, "sysdef", Integer.to_string(subject_params["sysdef"]))
        end


            cg = Subject.changeset(%Subject{}, subject_params)

        case Repo.insert(cg) do
          {:ok, subject} ->
            {:ok, subject}

          {:error, cg} ->
            {:error, cg}
        end
      end

    conn
    |> put_flash(:info, "Subjects created successfully.")
    |> redirect(to: subject_path(conn, :index))
  end
end
