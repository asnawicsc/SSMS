defmodule SchoolWeb.SubjectTeachClassController do
  use SchoolWeb, :controller
  require IEx
  alias School.Affairs
  alias School.Affairs.SubjectTeachClass

  def index(conn, _params) do
    subject_teach_class = Affairs.list_subject_teach_class()

    render(conn, "index.html", subject_teach_class: subject_teach_class)
  end

  def new(conn, _params) do
    changeset = Affairs.change_subject_teach_class(%SubjectTeachClass{})
    render(conn, "new.html", changeset: changeset)
  end

  def create_class_subject_teach(conn, params) do
    class_id = params["class_id"] |> String.to_integer()
    standard_id = params["standard_id"] |> String.to_integer()

    subject = params["subject"]
    teacher = params["teacher"]

    for item <- subject do
      id = item |> elem(0)
      subject_id = item |> elem(1) |> String.to_integer()

      teacher = Enum.filter(teacher, fn x -> x |> elem(0) == id end) |> hd

      teacher_id = teacher |> elem(1) |> String.to_integer()

      subject_teach_class_params = %{
        subject_id: subject_id,
        teacher_id: teacher_id,
        class_id: class_id,
        standard_id: standard_id
      }

      Affairs.create_subject_teach_class(subject_teach_class_params)
    end

    conn
    |> put_flash(:info, "Subject Teachers Successfully Created.")
    |> redirect(to: class_path(conn, :class_setting))
  end

  def edit_class_subject_teach(conn, params) do
    class_id = params["class_id"] |> String.to_integer()
    standard_id = params["standard_id"] |> String.to_integer()

    subject = params["subject"]
    teacher = params["teacher"]

    for item <- subject do
      id = item |> elem(0)
      subject_id = item |> elem(1) |> String.to_integer()

      teacher = Enum.filter(teacher, fn x -> x |> elem(0) == id end) |> hd

      teacher_id = teacher |> elem(1) |> String.to_integer()

      subject_teach_class_params = %{
        subject_id: subject_id,
        teacher_id: teacher_id,
        class_id: class_id,
        standard_id: standard_id
      }

      subject_teach_class = Affairs.get_subject_teach_class!(id)

      Affairs.update_subject_teach_class(subject_teach_class, subject_teach_class_params)
    end

    conn
    |> put_flash(:info, "Subject Teachers Successfully Assign.")
    |> redirect(to: class_path(conn, :class_setting))
  end

  def create(conn, %{"subject_teach_class" => subject_teach_class_params}) do
    case Affairs.create_subject_teach_class(subject_teach_class_params) do
      {:ok, subject_teach_class} ->
        conn
        |> put_flash(:info, "Subject teach class created successfully.")
        |> redirect(to: subject_teach_class_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    subject_teach_class = Affairs.get_subject_teach_class!(id)
    render(conn, "show.html", subject_teach_class: subject_teach_class)
  end

  def edit(conn, %{"id" => id}) do
    subject_teach_class = Affairs.get_subject_teach_class!(id)
    changeset = Affairs.change_subject_teach_class(subject_teach_class)
    render(conn, "edit.html", subject_teach_class: subject_teach_class, changeset: changeset)
  end

  def update(conn, %{"id" => id, "subject_teach_class" => subject_teach_class_params}) do
    subject_teach_class = Affairs.get_subject_teach_class!(id)

    case Affairs.update_subject_teach_class(subject_teach_class, subject_teach_class_params) do
      {:ok, subject_teach_class} ->
        conn
        |> put_flash(:info, "Subject teach class updated successfully.")
        |> redirect(to: subject_teach_class_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", subject_teach_class: subject_teach_class, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    subject_teach_class = Affairs.get_subject_teach_class!(id)
    {:ok, _subject_teach_class} = Affairs.delete_subject_teach_class(subject_teach_class)

    conn
    |> put_flash(:info, "Subject teach class deleted successfully.")
    |> redirect(to: subject_teach_class_path(conn, :index))
  end
end
