defmodule SchoolWeb.CoGradeController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.CoGrade

  def index(conn, _params) do
    co_grade = Affairs.list_co_grade()
    render(conn, "index.html", co_grade: co_grade)
  end

    def default_co_grade(conn,params)do

    Repo.delete_all(CoGrade)

  Affairs.create_co_grade(%{name: "A",min: 80,max: 100,gpa: 12.00})
  Affairs.create_co_grade(%{name: "B",min: 60,max: 79,gpa: 8.00})
  Affairs.create_co_grade(%{name: "C",min: 50,max: 59,gpa: 6.00})
  Affairs.create_co_grade(%{name: "D",min: 40,max: 49,gpa: 4.00})
  Affairs.create_co_grade(%{name: "E",min: 0,max: 39,gpa: 2.00})

 co_grade = Affairs.list_co_grade()
   conn
        |> put_flash(:info, "Co_Grade updated successfully.")
        |> redirect(to: co_grade_path(conn, :index, co_grade))
  end

  def new(conn, _params) do
    changeset = Affairs.change_co_grade(%CoGrade{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"co_grade" => co_grade_params}) do
    case Affairs.create_co_grade(co_grade_params) do
      {:ok, co_grade} ->
        conn
        |> put_flash(:info, "Co grade created successfully.")
        |> redirect(to: co_grade_path(conn, :show, co_grade))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    co_grade = Affairs.get_co_grade!(id)
    render(conn, "show.html", co_grade: co_grade)
  end

  def edit(conn, %{"id" => id}) do
    co_grade = Affairs.get_co_grade!(id)
    changeset = Affairs.change_co_grade(co_grade)
    render(conn, "edit.html", co_grade: co_grade, changeset: changeset)
  end

  def update(conn, %{"id" => id, "co_grade" => co_grade_params}) do
    co_grade = Affairs.get_co_grade!(id)

    case Affairs.update_co_grade(co_grade, co_grade_params) do
      {:ok, co_grade} ->
        conn
        |> put_flash(:info, "Co grade updated successfully.")
        |> redirect(to: co_grade_path(conn, :show, co_grade))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", co_grade: co_grade, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    co_grade = Affairs.get_co_grade!(id)
    {:ok, _co_grade} = Affairs.delete_co_grade(co_grade)

    conn
    |> put_flash(:info, "Co grade deleted successfully.")
    |> redirect(to: co_grade_path(conn, :index))
  end
end
