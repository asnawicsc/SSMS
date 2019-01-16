defmodule SchoolWeb.StudentCommentController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.StudentComment
  require IEx

  def index(conn, _params) do
    student_comment = Affairs.list_student_comment()
    render(conn, "index.html", student_comment: student_comment)
  end

  def student_comments(conn, _params) do
    classes =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    render(conn, "comments.html", classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_student_comment(%StudentComment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create_student_comment(conn, params) do
    semester_id = params["semester_id"]
    class_id = params["class_id"]

    comment1 =
      if params["comment1"] != nil do
        params["comment1"]
      else
        ""
      end

    comment2 =
      if params["comment2"] != nil do
        params["comment2"]
      else
        ""
      end

    comment3 =
      if params["comment3"] != nil do
        params["comment3"]
      else
        ""
      end

    if comment1 != "" do
      for item <- comment1 do
        student_id = item |> elem(0)
        comment_id = item |> elem(1)

        id =
          Repo.get_by(School.Affairs.StudentComment,
            student_id: student_id,
            semester_id: conn.private.plug_session["semester_id"],
            class_id: class_id
          )

        if id == nil do
          Affairs.create_student_comment(%{
            class_id: class_id,
            semester_id: conn.private.plug_session["semester_id"],
            student_id: student_id,
            comment1: comment_id
          })
        else
          Affairs.update_student_comment(id, %{comment1: comment_id})
        end
      end
    end

    if comment2 != "" do
      for item <- comment2 do
        student_id = item |> elem(0)
        comment_id = item |> elem(1)

        id =
          Repo.get_by(School.Affairs.StudentComment,
            student_id: student_id,
            semester_id: conn.private.plug_session["semester_id"],
            class_id: class_id
          )

        if id == nil do
          Affairs.create_student_comment(%{
            class_id: class_id,
            student_id: student_id,
            comment2: comment_id
          })
        else
          Affairs.update_student_comment(id, %{comment2: comment_id})
        end
      end
    end

    if comment3 != "" do
      for item <- comment3 do
        student_id = item |> elem(0)
        comment_id = item |> elem(1)

        id =
          Repo.get_by(School.Affairs.StudentComment,
            student_id: student_id,
            semester_id: conn.private.plug_session["semester_id"],
            class_id: class_id
          )

        if id == nil do
          Affairs.create_student_comment(%{
            class_id: class_id,
            student_id: student_id,
            comment3: comment_id
          })
        else
          Affairs.update_student_comment(id, %{comment3: comment_id})
        end
      end
    end

    conn
    |> put_flash(:info, "Student comment created successfully.")
    |> redirect(to: student_comment_path(conn, :mark_comment))
  end

  def mark_comments(conn, params) do
    class = Repo.get_by(School.Affairs.Class, %{id: params["id"]})
    comment = Affairs.list_comment()

    students =
      Repo.all(
        from(
          s in School.Affairs.StudentClass,
          left_join: a in School.Affairs.Student,
          on: s.sudent_id == a.id,
          left_join: b in School.Affairs.StudentComment,
          on: b.student_id == s.sudent_id,
          left_join: c in School.Affairs.Class,
          on: s.class_id == c.id,
          where:
            s.class_id == ^class.id and s.semester_id == ^conn.private.plug_session["semester_id"],
          select: %{
            student_id: a.id,
            chinese_name: a.chinese_name,
            name: a.name,
            class_name: c.name,
            coment1: b.comment1,
            coment2: b.comment2,
            coment3: b.comment3
          }
        )
      )

    if students != [] do
      render(conn, "student_comments.html", class: class, comment: comment, students: students)
    else
      conn
      |> put_flash(:info, "No Student In this Class Please Enroll Student first")
      |> redirect(to: student_comment_path(conn, :list_class_comment))
    end
  end

  def mark_comment(conn, params) do
    comment =
      Affairs.list_comment()
      |> Enum.filter(fn x -> x.institution_id == conn.private.plug_session["institution_id"] end)

    user = Repo.get_by(School.Settings.User, %{id: conn.private.plug_session["user_id"]})

    {students, teacher, class} =
      if user.role == "Admin" or user.role == "Support" do
        conn
        |> put_flash(:info, "You are not assign to any class")
        |> redirect(to: student_comment_path(conn, :list_class_comment))
      else
        teacher = Repo.get_by(School.Affairs.Teacher, %{email: user.email})
        class = Repo.get_by(School.Affairs.Class, %{teacher_id: teacher.id})

        students =
          Repo.all(
            from(
              s in School.Affairs.StudentClass,
              left_join: a in School.Affairs.Student,
              on: s.sudent_id == a.id,
              left_join: b in School.Affairs.StudentComment,
              on: b.student_id == s.sudent_id,
              left_join: c in School.Affairs.Class,
              on: s.class_id == c.id,
              where:
                s.class_id == ^class.id and
                  s.semester_id == ^conn.private.plug_session["semester_id"],
              select: %{
                student_id: a.id,
                chinese_name: a.chinese_name,
                name: a.name,
                class_name: c.name,
                coment1: b.comment1,
                coment2: b.comment2,
                coment3: b.comment3
              }
            )
          )

        comment = Affairs.list_comment()

        if students != [] do
          render(conn, "student_comments.html", class: class, comment: comment, students: students)
        else
          conn
          |> put_flash(:info, "You are not assign to any class")
          |> redirect(to: page_path(conn, :dashboard))
        end
      end
  end

  def list_class_comment(conn, params) do
    class =
      Repo.all(
        from(c in Class, where: c.institution_id == ^conn.private.plug_session["institution_id"])
      )

    render(conn, "list_class_comment.html", class: class)
  end

  def create(conn, %{"student_comment" => student_comment_params}) do
    case Affairs.create_student_comment(student_comment_params) do
      {:ok, student_comment} ->
        conn
        |> put_flash(:info, "Student comment created successfully.")
        |> redirect(to: student_comment_path(conn, :show, student_comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    student_comment = Affairs.get_student_comment!(id)
    render(conn, "show.html", student_comment: student_comment)
  end

  def edit(conn, %{"id" => id}) do
    student_comment = Affairs.get_student_comment!(id)
    changeset = Affairs.change_student_comment(student_comment)
    render(conn, "edit.html", student_comment: student_comment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "student_comment" => student_comment_params}) do
    student_comment = Affairs.get_student_comment!(id)

    case Affairs.update_student_comment(student_comment, student_comment_params) do
      {:ok, student_comment} ->
        conn
        |> put_flash(:info, "Student comment updated successfully.")
        |> redirect(to: student_comment_path(conn, :show, student_comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", student_comment: student_comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    student_comment = Affairs.get_student_comment!(id)
    {:ok, _student_comment} = Affairs.delete_student_comment(student_comment)

    conn
    |> put_flash(:info, "Student comment deleted successfully.")
    |> redirect(to: student_comment_path(conn, :index))
  end
end
