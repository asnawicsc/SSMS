defmodule SchoolWeb.UserChannel do
  use SchoolWeb, :channel
  require IEx
  alias School.Affairs
  alias School.Affairs.Subject
  alias School.Affairs.Teacher
  alias School.Affairs.Parent

  def join("user:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket |> assign(:locale, "zh")}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("show_height_weight", payload, socket) do
    std_id = payload["std_id"]
    lvl_id = payload["lvl_id"]
    student = Repo.get(Student, std_id)

    if student.weight != nil do
      weights = String.split(student.weight, ",")

      weight =
        for weight <- weights do
          l_id = String.split(weight, "-") |> List.to_tuple() |> elem(0)

          if l_id == payload["lvl_id"] do
            weight
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if weight != [] do
        weight = hd(weight) |> String.split("-") |> List.to_tuple() |> elem(1)
      else
        weight = nil
      end
    else
      weight = nil
    end

    if student.height != nil do
      heights = String.split(student.height, ",")

      height =
        for height <- heights do
          l_id = String.split(height, "-") |> List.to_tuple() |> elem(0)

          if l_id == payload["lvl_id"] do
            height
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if height != [] do
        height = hd(height) |> String.split("-") |> List.to_tuple() |> elem(1)
      else
        height = nil
      end
    else
      height = nil
    end

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.StudentView,
        "show_height_weight.html",
        student: student,
        height: height,
        weight: weight,
        std_id: std_id
      )

    broadcast(socket, "display_height_weight", %{html: html})
    {:noreply, socket}
  end

  def handle_in("submit_height_weight", payload, socket) do
    map =
      payload["map"]
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    student = Repo.get(Student, map["std_id"])

    if student.height == nil do
      height = Enum.join([payload["lvl_id"], map["height"]], "-")
      # weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
    else
      cur_height = Enum.join([payload["lvl_id"], map["height"]], "-")
      ex_height = String.split(student.height, ",")

      lists =
        for ex <- ex_height do
          l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

          if l_id != payload["lvl_id"] do
            ex
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if lists != [] do
        lists = Enum.join(lists, ",")
        height = Enum.join([lists, cur_height], ",")
      else
        height = Enum.join([payload["lvl_id"], map["height"]], "-")
      end
    end

    if student.weight == nil do
      weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
    else
      cur_weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
      ex_weight = String.split(student.weight, ",")

      lists2 =
        for ex <- ex_weight do
          l_id = String.split(ex, "-") |> List.to_tuple() |> elem(0)

          if l_id != payload["lvl_id"] do
            ex
          end
        end
        |> Enum.reject(fn x -> x == nil end)

      if lists2 != [] do
        lists2 = Enum.join(lists2, ",")
        weight = Enum.join([lists2, cur_weight], ",")
      else
        weight = Enum.join([payload["lvl_id"], map["weight"]], "-")
      end
    end

    Student.changeset(student, %{
      height: height,
      weight: weight
    })
    |> Repo.update()

    broadcast(socket, "updated_height_weight", %{})
    {:noreply, socket}
  end

  def handle_in("load_footer", payload, socket) do
    id = payload["inst_id"]
    inst = Repo.get(School.Settings.Institution, id)

    broadcast(socket, "show_footer", %{logo_bin: inst.logo_bin, maintain: inst.maintained_by})
    {:noreply, socket}
  end

  def handle_in("load_absent_reasons", payload, socket) do
    absent =
      Repo.all(
        from(
          a in Absent,
          where: a.absent_date == ^Date.utc_today() and a.student_id == ^payload["student_id"]
        )
      )

    if absent != [] do
      broadcast(socket, "show_reasons", %{
        student_id: hd(absent).student_id,
        reason: hd(absent).reason
      })
    end

    {:noreply, socket}
  end

  def handle_in("inquire_student_details", payload, socket) do
    id = payload["student_id"]
    user = Repo.get(School.Settings.User, payload["user_id"])
    student = Affairs.get_student!(id)
    changeset = Affairs.change_student(student)

    conn = %{
      private: %{
        plug_session: %{"institution_id" => user.institution_id, "user_id" => user.id}
      }
    }

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.StudentView,
        "form.html",
        student: student,
        guardian: student.gicno,
        father: student.ficno,
        mother: student.micno,
        changeset: changeset,
        conn: conn,
        action: "/students/#{student.id}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_student_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_subject_details", payload, socket) do
    code = payload["code"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    subject = Repo.get_by(Subject, code: code)
    changeset = Affairs.change_subject(subject)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.SubjectView,
        "form.html",
        code: code,
        changeset: changeset,
        conn: conn,
        action: "/subject/#{subject.code}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_subject_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_teacher_details", payload, socket) do
    code = payload["code"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    teacher = Repo.get_by(Teacher, code: code)
    changeset = Affairs.change_teacher(teacher)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.TeacherView,
        "form.html",
        code: code,
        changeset: changeset,
        conn: conn,
        action: "/teacher/#{teacher.code}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_teacher_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  def handle_in("inquire_parent_details", payload, socket) do
    icno = payload["icno"] |> String.trim(" ")

    user = Repo.get(School.Settings.User, payload["user_id"])

    parent = Repo.get_by(Parent, icno: icno)

    changeset = Affairs.change_parent(parent)

    conn = %{private: %{plug_session: %{"institution_id" => user.institution_id}}}

    html =
      Phoenix.View.render_to_string(
        SchoolWeb.ParentView,
        "form.html",
        icno: icno,
        changeset: changeset,
        conn: conn,
        action: "/parent/#{parent.icno}"
      )

    csrf = Phoenix.Controller.get_csrf_token()
    broadcast(socket, "show_parent_details", %{html: html, csrf: csrf})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
