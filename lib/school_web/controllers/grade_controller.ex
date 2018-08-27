defmodule SchoolWeb.GradeController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.Grade

  def index(conn, _params) do
    grade = Affairs.list_grade()
    render(conn, "index.html", grade: grade)
  end

  def default_grade(conn,params)do

    Repo.delete_all(Grade)

  Affairs.create_grade(%{name: "A",mix: 80,max: 100,gpa: 12.00})
  Affairs.create_grade(%{name: "B",mix: 60,max: 79,gpa: 8.00})
  Affairs.create_grade(%{name: "C",mix: 50,max: 59,gpa: 6.00})
  Affairs.create_grade(%{name: "D",mix: 40,max: 49,gpa: 4.00})
  Affairs.create_grade(%{name: "E",mix: 0,max: 39,gpa: 2.00})

 grade = Affairs.list_grade()
   conn
        |> put_flash(:info, "Grade updated successfully.")
        |> redirect(to: grade_path(conn, :index, grade))
  end

  def new(conn, _params) do
    changeset = Affairs.change_grade(%Grade{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"grade" => grade_params}) do
    case Affairs.create_grade(grade_params) do
      {:ok, grade} ->
        conn
        |> put_flash(:info, "Grade created successfully.")
        |> redirect(to: grade_path(conn, :show, grade))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    grade = Affairs.get_grade!(id)
    render(conn, "show.html", grade: grade)
  end

  def edit(conn, %{"id" => id}) do
    grade = Affairs.get_grade!(id)
    changeset = Affairs.change_grade(grade)
    render(conn, "edit.html", grade: grade, changeset: changeset)
  end

  def update(conn, %{"id" => id, "grade" => grade_params}) do
    grade = Affairs.get_grade!(id)

    case Affairs.update_grade(grade, grade_params) do
      {:ok, grade} ->
        conn
        |> put_flash(:info, "Grade updated successfully.")
        |> redirect(to: grade_path(conn, :show, grade))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", grade: grade, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    grade = Affairs.get_grade!(id)
    {:ok, _grade} = Affairs.delete_grade(grade)

    conn
    |> put_flash(:info, "Grade deleted successfully.")
    |> redirect(to: grade_path(conn, :index))
  end
end
