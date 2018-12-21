defmodule SchoolWeb.HistoryExamController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.HistoryExam
  alias School.Affairs.Exam
  alias School.Affairs.ExamPeriod
  alias School.Affairs.ExamMaster
  alias School.Affairs.Semester
  alias School.Affairs.Level
  alias School.Affairs.Subject
  alias School.Affairs.Student
  require IEx
  require Task

  def index(conn, _params) do
    history_exam = Affairs.list_history_exam()

    render(conn, "index.html", history_exam: history_exam)
  end

  def exam_history_checklist(conn, _params) do
    exam_semester =
      Repo.all(
        from(
          e in Exam,
          left_join: em in ExamMaster,
          on: em.id == e.exam_master_id,
          left_join: s in Subject,
          on: e.subject_id == s.id,
          left_join: sm in Semester,
          on: em.semester_id == sm.id,
          left_join: l in Level,
          on: em.level_id == l.id,
          group_by: [em.name, em.id, sm.start_date, sm.id],
          where: em.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            exam_name: em.name,
            semester: sm.start_date,
            semester_end: sm.end_date,
            semester_id: sm.id,
            exam_master_id: em.id
          }
        )
      )

    a = Affairs.list_history_exam()

    history_exam =
      if a != [] do
        Affairs.list_history_exam() |> hd
      else
        []
      end

    render(conn, "exam_history_checklist.html",
      history_exam: history_exam,
      exam_semester: exam_semester
    )
  end

  def generate_history_exam(conn, params) do
    exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.Exam,
          on: e.exam_id == k.id,
          left_join: g in School.Affairs.ExamMaster,
          on: g.id == k.exam_master_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: f in School.Affairs.Class,
          on: f.id == e.class_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where:
            g.id == ^params["exam_id"] and g.semester_id == ^params["semester_id"] and
              g.institution_id == ^conn.private.plug_session["institution_id"] and
              s.institution_id == ^conn.private.plug_session["institution_id"] and
              p.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{
            student_no: s.id,
            student_name: s.name,
            chinese_name: s.chinese_name,
            subject_code: p.code,
            subject_name: p.description,
            subject_mark: e.mark,
            class_name: f.name,
            exam_name: g.name
          }
        )
      )

    semester_id = params["semester_id"]

    semester = Affairs.get_semester!(semester_id)

    for params <- exam_mark do
      params = Map.put(params, :institution_id, conn.private.plug_session["institution_id"])
      params = Map.put(params, :semester_id, semester_id)
      params = Map.put(params, :year, semester.year)

      Affairs.create_history_exam(params)
    end

    conn
    |> put_flash(:info, "History exam created successfully.")
    |> redirect(to: history_exam_path(conn, :index))
  end

  def pre_generate_exam_record(conn, params) do
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

  def upload_exam_record(conn, params) do
    batch = Settings.get_batch!(params["batch_id"])
    bin = batch.result
    usr = Settings.current_user(conn)
    {:ok, batch} = Settings.update_batch(batch, %{upload_by: usr.id})

    data =
      if bin |> String.contains?("\r") do
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

    Task.start_link(__MODULE__, :loop, [conn, contents, headers, batch])

    conn
    |> put_flash(:info, "History Record successfully added.")
    |> redirect(to: exam_path(conn, :list_report_history))
  end

  def history_exam_result_class(conn, params) do
    all =
      Repo.all(
        from(s in HistoryExam,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{year: s.year, exam_name: s.exam_name, class_name: s.class_name}
        )
      )

    year =
      all
      |> Enum.map(fn x -> x.year end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != nil end)

    exam_name =
      all
      |> Enum.map(fn x -> x.exam_name end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != nil end)

    class_name =
      all
      |> Enum.map(fn x -> x.class_name end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != nil end)

    render(conn, "history_exam_result_class.html",
      year: year,
      exam_name: exam_name,
      class_name: class_name
    )
  end

  def loop(conn, contents, headers, batch) do
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

        exam_param = Enum.zip(h, c) |> Enum.into(%{})

        exam_param =
          Map.put(exam_param, "institution_id", conn.private.plug_session["institution_id"])

        cg = HistoryExam.changeset(%HistoryExam{}, exam_param)

        case Repo.insert(cg) do
          {:ok, student} ->
            exam_param
            exam_param = Map.put(exam_param, "reason", "ok")

          {:error, changeset} ->
            errors = changeset.errors |> Keyword.keys()

            {reason, message} = changeset.errors |> hd()
            {proper_message, message_list} = message
            final_reason = Atom.to_string(reason) <> " " <> proper_message
            exam_param = Map.put(exam_param, "reason", final_reason)

            exam_param
        end
      end

    header = result |> hd() |> Map.keys()
    body = result |> Enum.map(fn x -> Map.values(x) end)
    new_io = List.insert_at(body, 0, header) |> CSV.encode() |> Enum.to_list() |> to_string
    {:ok, batch} = Settings.update_batch(batch, %{result: new_io})
  end

  def history_exam_report_class(conn, params) do
    history_data =
      Repo.all(
        from(s in HistoryExam,
          where:
            s.class_name == ^params["class_name"] and s.year == ^params["year"] and
              s.exam_name == ^params["exam_name"] and
              s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    if history_data == [] do
      conn
      |> put_flash(:info, "No History Record for this selection.")
      |> redirect(to: history_exam_path(conn, :history_exam_result_class))
    else
      all_stud =
        for history <- history_data |> Enum.group_by(fn x -> x.student_no end) do
          data = history |> elem(1)

          each =
            for item <- data do
              %{
                student_no: item.student_no,
                student_name: item.student_name,
                chinese_name: item.chinese_name,
                subject_code: item.subject_code,
                subject_name: item.subject_name,
                subject_mark: item.subject_mark
              }
            end

          each
        end
        |> List.flatten()

      a = all_stud |> Enum.group_by(fn x -> x.student_no end)

      render(conn, "result_history_exam_class.html",
        a: a,
        class_name: params["class_name"],
        year: params["year"],
        exam_name: params["exam_name"]
      )
    end
  end

  def new(conn, _params) do
    changeset = Affairs.change_history_exam(%HistoryExam{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"history_exam" => history_exam_params}) do
    case Affairs.create_history_exam(history_exam_params) do
      {:ok, history_exam} ->
        conn
        |> put_flash(:info, "History exam created successfully.")
        |> redirect(to: history_exam_path(conn, :show, history_exam))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    history_exam = Affairs.get_history_exam!(id)
    render(conn, "show.html", history_exam: history_exam)
  end

  def edit(conn, %{"id" => id}) do
    history_exam = Affairs.get_history_exam!(id)
    changeset = Affairs.change_history_exam(history_exam)
    render(conn, "edit.html", history_exam: history_exam, changeset: changeset)
  end

  def update(conn, %{"id" => id, "history_exam" => history_exam_params}) do
    history_exam = Affairs.get_history_exam!(id)

    case Affairs.update_history_exam(history_exam, history_exam_params) do
      {:ok, history_exam} ->
        conn
        |> put_flash(:info, "History exam updated successfully.")
        |> redirect(to: history_exam_path(conn, :show, history_exam))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", history_exam: history_exam, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    history_exam = Affairs.get_history_exam!(id)
    {:ok, _history_exam} = Affairs.delete_history_exam(history_exam)

    conn
    |> put_flash(:info, "History exam deleted successfully.")
    |> redirect(to: history_exam_path(conn, :index))
  end
end
