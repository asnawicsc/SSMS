defmodule SchoolWeb.SubjectController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.Subject

  def index(conn, _params) do
    subjects =
      Affairs.list_subject()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", subjects: subjects)
  end

  def new_standard_subject(conn, params) do
    subjects =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          select: %{
            id: s.id,
            code: s.code,
            timetable_code: s.timetable_code,
            name: s.description,
            timetable_description: s.timetable_description,
            institution_id: s.institution_ids
          }
        )
        |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)
      )

    semester =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          select: %{id: s.id, start_date: s.start_date, institution_id: s.institution_id}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    level =
      Repo.all(
        from(
          s in School.Affairs.Level,
          select: %{id: s.id, name: s.name, institution_id: s.institution_id}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "index.html", subjects: subjects, semester: semester, level: level)
  end

  def subject_setting(conn, params) do
    subjects =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          select: %{
            id: s.id,
            code: s.code,
            timetable_code: s.timetable_code,
            name: s.description,
            timetable_description: s.timetable_description,
            with_mark: s.with_mark,
            institution_id: s.institution_id
          }
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "subject_setting.html", subjects: subjects)
  end

  def create_subject_setting(conn, params) do
    subjects =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          select: %{
            id: s.id,
            code: s.code,
            timetable_code: s.timetable_code,
            name: s.description,
            timetable_description: s.timetable_description,
            with_mark: s.with_mark,
            institution_id: s.institution_id
          }
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    for item <- subjects do
      subject = Affairs.get_subject!(item.id)
      Affairs.update_subject(subject, %{with_mark: 0})
    end

    for item <- params["subject"] do
      subject_id = item |> elem(0)
      subject = Affairs.get_subject!(subject_id)
      Affairs.update_subject(subject, %{with_mark: 1})
    end

    conn
    |> put_flash(:info, "Subject setting updated successfully.")
    |> redirect(to: subject_path(conn, :subject_setting))
  end

  def create_new_test(conn, _params) do
    subjects =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          select: %{id: s.id, code: s.code, name: s.description, institution_id: s.institution_id}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    semester =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          select: %{id: s.id, start_date: s.start_date, institution_id: s.institution_id}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    level =
      Repo.all(
        from(
          s in School.Affairs.Level,
          select: %{id: s.id, name: s.name, institution_id: s.institution_id}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(conn, "new_exam.html", subjects: subjects, semester: semester, level: level)
  end

  def new(conn, _params) do
    changeset = Affairs.change_subject(%Subject{})
    render(conn, "new.html", changeset: changeset)
  end

  def standard_setting(conn, params) do
    subject = Affairs.list_subject()
    period = Affairs.list_period()

    subjects =
      Repo.all(
        from(
          s in School.Affairs.Subject,
          select: %{
            institution_id: s.institution_id,
            id: s.id,
            code: s.code,
            timetable_code: s.timetable_code,
            name: s.description,
            timetable_description: s.timetable_description,
            description: s.description,
            cdesc: s.cdesc
          }
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    semester =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          select: %{institution_id: s.institution_id, id: s.id, start_date: s.start_date}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    level =
      Repo.all(
        from(
          s in School.Affairs.Level,
          select: %{institution_id: s.institution_id, id: s.id, name: s.name}
        )
      )
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    grade =
      Affairs.list_grade()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    co_grade =
      Affairs.list_co_grade()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    standard_subject =
      Affairs.list_standard_subject()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    exam_master =
      Affairs.list_exam_master()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    render(
      conn,
      "standard_setting.html",
      period: period,
      exam_master: exam_master,
      standard_subject: standard_subject,
      co_grade: co_grade,
      grade: grade,
      subject: subject,
      subjects: subjects,
      semester: semester,
      level: level
    )
  end

  def assign_class(conn, %{"id" => id}) do
    Affairs.get_inst_id(conn)
    subject = Affairs.get_subject!(id)

    classes = Affairs.get_inst_id(conn) |> Affairs.list_classes()

    render(
      conn,
      "assign_class.html",
      classes: classes
    )
  end

  def create(conn, %{"subject" => subject_params}) do
    inst_id = Affairs.get_inst_id(conn)
    subject_params = Map.put(subject_params, "institution_id", inst_id)

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
    subject = Repo.get_by(Subject, id: id)

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
    data = bin |> String.split("\n") |> Enum.map(fn x -> String.split(x, ",") end)
    headers = hd(data) |> Enum.map(fn x -> String.trim(x, " ") end)
    contents = tl(data)

    subject_params =
      for content <- contents do
        h = headers |> Enum.map(fn x -> String.downcase(x) end)

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

        subject_params =
          Map.put(subject_params, "institution_id", conn.private.plug_session["institution_id"])

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
