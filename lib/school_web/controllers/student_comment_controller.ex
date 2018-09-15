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
   classes = Repo.all(from(c in Class, where: c.institution_id == ^User.institution_id(conn)))
    render(conn, "comments.html",classes: classes)
  end

  def new(conn, _params) do
    changeset = Affairs.change_student_comment(%StudentComment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create_student_comment(conn, params) do

    semester_id=params["semester_id"]
    class_id=params["class_id"]

     comment1=
     if  params["comment1"] != nil  do
     params["comment1"]
    else
      ""
      
    end

       comment2=
     if  params["comment2"] != nil  do
     params["comment2"]
    else
      ""
      
    end

       comment3=
     if  params["comment3"] != nil  do
     params["comment3"]
    else
      ""
    end
    


if  comment1 != "" do
    
for item <- comment1 do

  student_id=item|>elem(0)
  comment_id=item|>elem(1)

  id=Repo.get_by(School.Affairs.StudentComment,student_id: student_id,semester_id: semester_id,class_id: class_id)

  if id == nil do

    Affairs.create_student_comment(%{class_id: class_id,semester_id: semester_id,student_id: student_id,comment1: comment_id})
  else
    Affairs.update_student_comment(id,%{comment1: comment_id})
    
  end
  
end

end

if comment2 != ""  do

for item <- comment2 do

    student_id=item|>elem(0)
  comment_id=item|>elem(1)

  id=Repo.get_by(School.Affairs.StudentComment,student_id: student_id,semester_id: semester_id,class_id: class_id)

  if id == nil do

    Affairs.create_student_comment(%{class_id: class_id,semester_id: semester_id,student_id: student_id,comment2: comment_id})
  else
    Affairs.update_student_comment(id,%{comment2: comment_id})
    
  end
  
end

end

if comment3 != ""  do
  

for item <- comment3 do

    student_id=item|>elem(0)
  comment_id=item|>elem(1)

  id=Repo.get_by(School.Affairs.StudentComment,student_id: student_id,semester_id: semester_id,class_id: class_id)

  if id == nil do

    Affairs.create_student_comment(%{class_id: class_id,semester_id: semester_id,student_id: student_id,comment3: comment_id})
  else
    Affairs.update_student_comment(id,%{comment3: comment_id})
    
  end
  
end

end

conn
        |> put_flash(:info, "Student comment created successfully.")
        |> redirect(to: student_comment_path(conn, :index))
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
