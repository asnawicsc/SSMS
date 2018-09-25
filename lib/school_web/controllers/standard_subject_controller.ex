defmodule SchoolWeb.StandardSubjectController do
  use SchoolWeb, :controller
  require IEx
  alias School.Affairs
  alias School.Affairs.StandardSubject

  def index(conn, _params) do
    standard_subject = Affairs.list_standard_subject()
    render(conn, "index.html", standard_subject: standard_subject)
  end

  def create_standard_subject(conn, params) do
    level_id = params["level"] |> String.to_integer()
    semester_id = params["semester"] |> String.to_integer()
    year = params["year"]
    subjects = params["standard_subject"] |> String.split(",")

    for subject <- subjects do
      subject = subject |> String.to_integer()

      standard_subject_params = %{
        standard_id: level_id,
        semester_id: semester_id,
        year: year,
        subject_id: subject
      }

      changeset = Affairs.change_standard_subject(%StandardSubject{})

      standard_subject_params =
        Map.put(
          standard_subject_params,
          :institution_id,
          conn.private.plug_session["institution_id"]
        )

      Affairs.create_standard_subject(standard_subject_params)
    end

    conn
    |> put_flash(:info, "Standard Subject Created.")
    |> redirect(to: subject_path(conn, :standard_setting))
  end

  def new(conn, _params) do
    changeset = Affairs.change_standard_subject(%StandardSubject{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"standard_subject" => standard_subject_params}) do
    case Affairs.create_standard_subject(standard_subject_params) do
      {:ok, standard_subject} ->
        conn
        |> put_flash(:info, "Standard subject created successfully.")
        |> redirect(to: standard_subject_path(conn, :show, standard_subject))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    standard_subject = Affairs.get_standard_subject!(id)
    render(conn, "show.html", standard_subject: standard_subject)
  end

  def edit(conn, %{"id" => id}) do
    standard_subject = Affairs.get_standard_subject!(id)
    changeset = Affairs.change_standard_subject(standard_subject)
    render(conn, "edit.html", standard_subject: standard_subject, changeset: changeset)
  end

  def update(conn, %{"id" => id, "standard_subject" => standard_subject_params}) do
    standard_subject = Affairs.get_standard_subject!(id)

    case Affairs.update_standard_subject(standard_subject, standard_subject_params) do
      {:ok, standard_subject} ->
        conn
        |> put_flash(:info, "Standard subject updated successfully.")
        |> redirect(to: standard_subject_path(conn, :show, standard_subject))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", standard_subject: standard_subject, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    standard_subject = Affairs.get_standard_subject!(id)
    {:ok, _standard_subject} = Affairs.delete_standard_subject(standard_subject)

    conn
    |> put_flash(:info, "Standard subject deleted successfully.")
    |> redirect(to: standard_subject_path(conn, :index))
  end
end
