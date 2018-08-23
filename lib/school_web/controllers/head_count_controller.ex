defmodule SchoolWeb.HeadCountController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.HeadCount

  def index(conn, _params) do
    head_counts = Affairs.list_head_counts()
    render(conn, "index.html", head_counts: head_counts)
  end

   def generate_head_count(conn, %{"id" => id}) do
    all =
      Repo.all(
        from(
          p in School.Affairs.Period,
          left_join: sb in School.Affairs.Subject,
          on: sb.id == p.subject_id,
          left_join: s in School.Affairs.Class,
          on: p.class_id == s.id,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          where: p.class_id == ^id,
          select: %{id: sb.id, t_name: t.name, s_code: sb.code, subject: sb.description}
        )
      )
      |> Enum.uniq()
      |> Enum.filter(fn x -> x.t_name != "Rest" end)



    render(conn, "generate_head_count.html", all: all, id: id)
  end

  def head_count_create(conn, params) do
    class_id = params["class_id"]
    subject_id = params["subject"]
  

    all =
      Repo.all(
        from(
          s in School.Affairs.HeadCount,
          where: s.class_id == ^class_id and s.subject_id == ^subject_id ,
          select: %{
            class_id: s.class_id,
            subject_id: s.subject_id,
            student_id: s.student_id,
            mark: s.targer_mark
          }
        )
      )

    if all == [] do
      class = Affairs.get_class!(class_id)
      subject = Affairs.get_subject!(subject_id)

     
      student =
        Repo.all(
          from(
            s in School.Affairs.StudentClass,
            left_join: p in Student,
            on: p.id == s.sudent_id,
            where: s.class_id == ^class_id,
            select: %{id: p.id, student_name: p.name}
          )
        )

      render(
        conn,
        "head_count_create.html",
        student: student,
        class: class,
        subject: subject
      
      )
    else
      class_id = all |> Enum.map(fn x -> x.class_id end) |> Enum.uniq() |> hd
      subject_id = all |> Enum.map(fn x -> x.subject_id end) |> Enum.uniq() |> hd

      class = Affairs.get_class!(class_id)
      subject = Affairs.get_subject!(subject_id)

      render(
        conn |> put_flash(:info, "Exam  target mark already filled, please edit existing mark."),
        "edit_head_count.html",
        all: all,
        class: class,
        subject: subject
      )
    end
  end

   def create_head_count(conn, params) do
    class_id = params["class_id"]
    mark = params["mark"]
    subject_id = params["subject_id"]


    for item <- mark do
      student_id = item |> elem(0)
      mark = item |> elem(1)

      head_count_params = %{
        class_id: class_id,
        targer_mark: mark,
        subject_id: subject_id,
        student_id: student_id
      }


      Affairs.create_head_count(head_count_params)
    end

    conn
    |> put_flash(:info, "Exam target mark created successfully.")
    |> redirect(to: class_path(conn, :index))
  end

   def update_head_count_mark(conn, params) do
    class_id = params["class_id"]
    mark = params["mark"]
    subject_id = params["subject_id"]
  

    for item <- mark do
      student_id = item |> elem(0)
      mark = item |> elem(1)

      exam_mark =
        Repo.get_by(School.Affairs.HeadCount, %{
          subject_id: subject_id,
          student_id: student_id
        })

      exam_mark_params = %{
        class_id: class_id,
        targer_mark: mark,
        subject_id: subject_id,
        student_id: student_id
      }

      Affairs.update_head_count(exam_mark, exam_mark_params)
    end

    conn
    |> put_flash(:info, "Exam target mark updated successfully.")
    |> redirect(to: class_path(conn, :index))
  end

  def head_count_subject(conn, %{"id" => id}) do
      all =
      Repo.all(
        from(
          p in School.Affairs.Period,
          left_join: sb in School.Affairs.Subject,
          on: sb.id == p.subject_id,
          left_join: s in School.Affairs.Class,
          on: p.class_id == s.id,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          where: p.class_id == ^id,
          select: %{id: sb.id, t_name: t.name, s_code: sb.code, subject: sb.description}
        )
      )
      |> Enum.uniq()
      |> Enum.filter(fn x -> x.t_name != "Rest" end)


        render(conn, "head_count_subject.html", all: all, id: id)
  end

  def head_count_subject_create(conn, params) do
        class = Affairs.get_class!(params["class_id"])
         subject = Affairs.get_subject!(params["subject"])

         period=Repo.all(from p in School.Affairs.Period, where: p.class_id==^class.id and p.subject_id==^subject.id)|>hd
         teacher_id=period.teacher_id

         teacher_name=Affairs.get_teacher!(teacher_id)


    head_count_mark =
      Repo.all(
        from(
          e in School.Affairs.HeadCount,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where: e.class_id == ^class.id and e.subject_id==^subject.id,
          select: %{
            subject_code: p.code,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.targer_mark
          }
        )
      )

      if head_count_mark ==[]  do
          conn
        |> put_flash(:info, "Head count for this subject is not created yet!.")
        |> redirect(to: class_path(conn, :index))

      else

   

        exam_mark =
      Repo.all(
        from(
          e in School.Affairs.ExamMark,
          left_join: k in School.Affairs.ExamMaster,
          on: k.id == e.exam_id,
          left_join: s in School.Affairs.Student,
          on: s.id == e.student_id,
          left_join: p in School.Affairs.Subject,
          on: p.id == e.subject_id,
          where: e.class_id == ^class.id and e.subject_id==^subject.id,
          select: %{
            subject_code: p.code,
            exam_name: k.name,
            student_id: s.id,
            student_name: s.name,
            student_mark: e.mark,
            sex: s.sex
          }
        )
      )



      if exam_mark != [] do
      exam_name = exam_mark |>Enum.group_by(fn x -> x.exam_name end)



              mark1 =
        for item <- exam_name do
          exam_name = item |> elem(0)

          datas = item |> elem(1)

          for data <- datas do
            student_mark = data.student_mark

       

            grades = Repo.all(from(g in School.Affairs.Grade))

            for grade <- grades do
              if student_mark >= grade.mix and student_mark <= grade.max do
                %{
                  exam: exam_name,
                  student_id: data.student_id,
                  student_name: data.student_name,
                  grade: grade.name,
                  gpa: grade.gpa,
                  subject_code: data.subject_code,
                  student_mark: data.student_mark,
                  sex: data.sex
                }
              end
            end
          end
        end
        |> List.flatten()
        |> Enum.filter(fn x -> x != nil end)


          news = mark1 |> Enum.group_by(fn x -> x.student_name end)




          detail=for new <- news do

             student_id = new |> elem(1) |> Enum.map(fn x -> x.student_id end) |> Enum.uniq() |> hd
              sex = new |> elem(1) |> Enum.map(fn x -> x.sex end) |> Enum.uniq() |> hd


                             head_count_mark =
              Repo.all(
                from(
                  e in School.Affairs.HeadCount,
                  left_join: s in School.Affairs.Student,
                  on: s.id == e.student_id,
                  left_join: p in School.Affairs.Subject,
                  on: p.id == e.subject_id,
                  where: e.class_id == ^class.id and e.subject_id==^subject.id and e.student_id==^student_id,
                  select: %{
                    subject_code: p.code,
                    student_id: s.id,
                    student_name: s.name,
                    student_mark: e.targer_mark,
                    sex: s.sex
                  }
                )
              )|>hd

        

             student_mark = head_count_mark.student_mark

              grades = Repo.all(from(g in School.Affairs.Grade))

            grade=for grade <- grades do
              if student_mark >= grade.mix and student_mark <= grade.max do
                %{
                
                  grade: grade.name,       
                  target_mark: student_mark
                }
              else

              end
            end|> List.flatten()
                |> Enum.filter(fn x -> x != nil end)|>hd
     
       

         
        %{
            subject: new |> elem(1) |> Enum.sort_by(fn x -> x.exam end),
            name: new |> elem(0),
            student_id: student_id,
            target_grade: grade.grade,
            target_mark: grade.target_mark,
            sex: sex
            
          }
        end|>Enum.with_index
   

        mark=exam_mark|>Enum.group_by(fn x -> x.exam_name end)



          render(conn, "head_counts.html",mark: mark, detail: detail, subject_name: subject.description, class_name: class.name,teacher_name: teacher_name)


   
    end


    end
    


  end

  def new(conn, _params) do
    changeset = Affairs.change_head_count(%HeadCount{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"head_count" => head_count_params}) do
    case Affairs.create_head_count(head_count_params) do
      {:ok, head_count} ->
        conn
        |> put_flash(:info, "Head count created successfully.")
        |> redirect(to: head_count_path(conn, :show, head_count))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    head_count = Affairs.get_head_count!(id)
    render(conn, "show.html", head_count: head_count)
  end

  def edit(conn, %{"id" => id}) do
    head_count = Affairs.get_head_count!(id)
    changeset = Affairs.change_head_count(head_count)
    render(conn, "edit.html", head_count: head_count, changeset: changeset)
  end

  def update(conn, %{"id" => id, "head_count" => head_count_params}) do
    head_count = Affairs.get_head_count!(id)

    case Affairs.update_head_count(head_count, head_count_params) do
      {:ok, head_count} ->
        conn
        |> put_flash(:info, "Head count updated successfully.")
        |> redirect(to: head_count_path(conn, :show, head_count))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", head_count: head_count, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    head_count = Affairs.get_head_count!(id)
    {:ok, _head_count} = Affairs.delete_head_count(head_count)

    conn
    |> put_flash(:info, "Head count deleted successfully.")
    |> redirect(to: head_count_path(conn, :index))
  end
end
