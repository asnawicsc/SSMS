defmodule SchoolWeb.ExamController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Exam
  alias School.Affairs.ExamMaster
  require IEx

  def index(conn, _params) do
    exam = Affairs.list_exam()
    render(conn, "index.html", exam: exam)
  end

  def new(conn, _params) do
    changeset = Affairs.change_exam(%Exam{})
    render(conn, "new.html", changeset: changeset)
  end

  def new_exam(conn, params) do
 
subjects=Repo.all(from s in School.Affairs.Subject,select: %{id: s.id,code: s.code, name: s.description})
semester=Repo.all(from s in School.Affairs.Semester,select: %{id: s.id,start_date: s.start_date})
level=Repo.all(from s in School.Affairs.Level,select: %{id: s.id,name: s.name})
        render(conn, "new_exam.html",subjects: subjects,semester: semester,level: level)
   
  end

    def create_exam(conn, params) do

      exam_name=params["exam_name"]
      level_id=params["level"]
      semester_id=params["semester"]
      year=params["year"]
      subjects=params["subject"]|> String.split(",")




      exam_master_params=%{name: exam_name, level_id: level_id,semester_id: semester_id,year: year}


    case Affairs.create_exam_master(exam_master_params) do
      {:ok, exam_master} ->
        
        id=exam_master.id  

        for subject <- subjects do
          exam_params=%{exam_master_id: id,subject_id: subject}
          changeset = Affairs.change_exam(%Exam{})
          Affairs.create_exam(exam_params)
             
        end   
        conn
        |> put_flash(:info, "Exam created successfully.")
        |> redirect(to: exam_master_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end

  end


  def create(conn, %{"exam" => exam_params}) do
    case Affairs.create_exam(exam_params) do
      {:ok, exam} ->
        conn
        |> put_flash(:info, "Exam created successfully.")
        |> redirect(to: exam_path(conn, :show, exam))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

    def generate_exam(conn, %{"id" => id}) do


      all=Repo.all(from p in  School.Affairs.Period, 
         left_join: sb in School.Affairs.Subject, on: sb.id == p.subject_id,
       left_join: s in School.Affairs.Class, on: p.class_id == s.id,
       left_join: t in School.Affairs.Teacher, on: t.id == p.teacher_id,
        where: p.class_id==^id,
        select: %{id: sb.id,t_name: t.name,s_code: sb.code, subject: sb.description })
      |>Enum.uniq|>Enum.filter(fn x -> x.t_name != "Rest" end)

      exam=Repo.all(from e in School.Affairs.ExamMaster,
        left_join: c in School.Affairs.Class, on: c.level_id== e.level_id,
        where: c.id==^id,select: %{id: e.id, exam_name: e.name})



    render(conn, "generate_exam.html",all: all,id: id,exam: exam)
  end

  def mark(conn, params) do

       class_id=params["class_id"]
        subject_id=params["subject"]
        exam_id=params["exam_id"]

    all=Repo.all(from s in School.Affairs.ExamMark,where: s.class_id==^class_id and s.subject_id==^subject_id and s.exam_id==^exam_id,
      select: %{class_id: s.class_id,subject_id: s.subject_id,exam_id: s.exam_id,student_id: s.student_id,mark: s.mark})

    if all ==[]  do
      
        class=Affairs.get_class!(class_id)
        subject=Affairs.get_subject!(subject_id)


       verify= Repo.all(from s in School.Affairs.Period, where: s.class_id==^class_id and s.subject_id==^subject_id,select: %{teacher_id: s.teacher_id})

       if verify == [] do

       else
         
       end

       student=Repo.all(from s in School.Affairs.StudentClass,
       left_join: p in Student, on: p.id==s.sudent_id,where: s.class_id==^class_id,select: %{id: p.id,student_name: p.name})


        render(conn, "mark.html",student: student,class: class,subject: subject,exam_id: exam_id)
    else



      class_id=all|>Enum.map(fn x -> x.class_id end)|>Enum.uniq|>hd
      exam_id=all|>Enum.map(fn x -> x.exam_id end)|>Enum.uniq|>hd
      subject_id=all|>Enum.map(fn x -> x.subject_id end)|>Enum.uniq|>hd


        class=Affairs.get_class!(class_id)
        subject=Affairs.get_subject!(subject_id)




      render(conn|> put_flash(:info, "Exam  mark already filled, please edit existing mark."), "edit_mark.html",all: all,class: class,exam_id: exam_id,subject: subject)


    end
  end


  def create_mark(conn, params) do

    class_id=params["class_id"]
    mark=params["mark"]
    subject_id=params["subject_id"]
    exam_id=params["exam_id"]

        a=Affairs.get_exam_master!(exam_id)
    exam_name=a.name


    for item <- mark do

      student_id=item|>elem(0)
      mark=item|>elem(1)

      exam_mark_params=%{class_id: class_id, exam_id: exam_id,mark: mark,subject_id: subject_id,student_id: student_id}

    Affairs.create_exam_mark(exam_mark_params)
    
      
    end

      conn
        |> put_flash(:info, "Exam mark created successfully.")
        |> redirect(to: class_path(conn, :index))

  end

  def update_mark(conn, params) do


  class_id=params["class_id"]
    mark=params["mark"]
    subject_id=params["subject_id"]
    exam_id=params["exam_id"]


    a=Affairs.get_exam_master!(exam_id)
    exam_name=a.name

    for item <- mark do

      student_id=item|>elem(0)
      mark=item|>elem(1)

          exam_mark=Repo.get_by(School.Affairs.ExamMark, %{exam_id: exam_id,subject_id: subject_id,student_id: student_id})

      exam_mark_params=%{class_id: class_id, exam_id: exam_id,mark: mark,subject_id: subject_id,student_id: student_id}

    Affairs.update_exam_mark(exam_mark,exam_mark_params)
    
      
    end

      conn
        |> put_flash(:info, "Exam mark updated successfully.")
        |> redirect(to: class_path(conn, :index))
 
  end

  def rank(conn, %{"id" => id}) do
    class = Affairs.get_class!(id)


   exam_mark=Repo.all(from e in School.Affairs.ExamMark,
   left_join: k in School.Affairs.ExamMaster, on: k.id==e.exam_id,
   left_join: s in School.Affairs.Student, on: s.id==e.student_id,
   left_join: p in School.Affairs.Subject, on: p.id==e.subject_id,
   where: e.class_id==^id,select: %{subject_code: p.code,exam_name: k.name,student_id: s.id, student_name: s.name,student_mark: e.mark})

if exam_mark != [] do
  


exam_name=exam_mark|>Enum.map(fn x -> x.exam_name end)|>Enum.uniq|>hd

all_mark=exam_mark |>Enum.group_by(fn x -> x.subject_code end)

   mark1=for item <- all_mark do

    subject_code=item|>elem(0)

    datas=item|>elem(1)

    for data <- datas do

    student_mark=data.student_mark

       grades=Repo.all(from g in School.Affairs.Grade)

       for grade <- grades do

        if student_mark >= grade.mix and student_mark <= grade.max do
          
          %{student_id: data.student_id,student_name: data.student_name,grade: grade.name,gpa: grade.gpa,subject_code: subject_code, student_mark: student_mark}

        end

         
       end


      
    end
   
   end|>List.flatten|>Enum.filter(fn x -> x != nil end)


   news=mark1|>Enum.group_by(fn x -> x.student_name end)


   z=for new <- news do


     total=new|>elem(1)|>Enum.map(fn x -> x.student_mark end)|>Enum.sum

           per= new|>elem(1)|>Enum.map(fn x -> x.student_mark end)|>Enum.count
          total_per=per *100 
     
      student_id=new|>elem(1)|>Enum.map(fn x -> x.student_id end)|>Enum.uniq|>hd

           a=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="A" end)  
           b=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="B" end)  
          c=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="C" end) 
           d=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="D" end) 
           e=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="E" end) 
           f=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="F" end)  
           g=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="G" end)  

           total_gpa= new|>elem(1)|>Enum.map(fn x -> Decimal.to_float(x.gpa) end)|>Enum.sum 
            cgpa = (total_gpa/per)|>Float.round(2) 

      %{subject: new|>elem(1)|>Enum.sort_by(fn x -> x.subject_code end),name: new|>elem(0),student_id: student_id,total_mark: total,per: per, total_per: total_per, a: a ,b: b,c: c,d: d ,e: e,f: f,g: g, cgpa: cgpa}  
   end|>Enum.sort_by(fn x -> x.total_mark end)|>Enum.reverse



   mark=mark1|>Enum.group_by(fn x -> x.subject_code end)

    render(conn, "rank.html",z: z,exam_name: exam_name,mark: mark,mark1: mark1)

  else
    conn
     |> put_flash(:info, "Please Insert Exam Record First")
        |> redirect(to: class_path(conn, :index))


    end
  end

   def report_card(conn, %{"id" => id,"exam_name" => exam_name}) do
 
    student = Affairs.get_student!(id)

    all=Repo.all(from em in School.Affairs.ExamMark,
      left_join: e in School.Affairs.ExamMaster, on: em.exam_id==e.id,
      left_join: j in School.Affairs.Semester, on: e.semester_id==j.id,
      left_join: s in School.Affairs.Student, on: em.student_id==s.id,
      left_join: sc in School.Affairs.StudentClass, on: sc.sudent_id==s.id,
      left_join: c in School.Affairs.Class, on: sc.class_id==c.id,
      left_join: sb in School.Affairs.Subject,on: em.subject_id==sb.id,
      where: em.student_id==^student.id and e.name==^exam_name,
      select: %{student_name: s.name,
      class_name: c.name,
      semester: j.id,
      subject_code: sb.code,
      subject_name: sb.description,
      mark: em.mark })


    all_data=for data <- all do

       grades=Repo.all(from g in School.Affairs.Grade)

       for grade <- grades do

          if data.mark >= grade.mix and data.mark <= grade.max do
            
            %{class_name: data.class_name,semester: data.semester,student_name: data.student_name,grade: grade.name,gpa: grade.gpa,subject_code: data.subject_code,subject_name: data.subject_name, student_mark: data.mark}

          end
         
       end
      
    end|>List.flatten|>Enum.filter(fn x -> x != nil end)


student_name=all_data|>Enum.map(fn x -> x.student_name end)|>Enum.uniq|>hd

class_name=all_data|>Enum.map(fn x -> x.class_name end)|>Enum.uniq|>hd



           a=all_data|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="A" end)  
           b=all_data|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="B" end)  
          c=all_data|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="C" end) 
           d=all_data|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="D" end) 
           e=all_data|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="E" end) 
           f=all_data|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="F" end)  
           g=all_data|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="G" end)  

            per= all_data|>Enum.map(fn x -> x.student_mark end)|>Enum.count
        total_gpa= all_data|>Enum.map(fn x -> Decimal.to_float(x.gpa) end)|>Enum.sum 
            cgpa = (total_gpa/per)|>Float.round(2) 
         

  

    render(conn, "report_card.html",total_gpa: total_gpa, a: a ,b: b,c: c,d: d ,e: e,f: f,g: g, cgpa: cgpa,  all_data: all_data,student_name: student_name,class_name: class_name)
  end

  def generate_ranking(conn, params) do

    level=Repo.all(from l in School.Affairs.Level)
    semester=Repo.all(from s in School.Affairs.Semester)
    
    render(conn, "generate_ranking.html",semester: semester,level: level)
  end


   def exam_ranking(conn, params) do

    exam_id=params["exam_id"]
    semester_id=params["semester_id"]



   exam_mark=Repo.all(from e in School.Affairs.ExamMark,
   left_join: k in School.Affairs.ExamMaster, on: k.id==e.exam_id,
   left_join: s in School.Affairs.Student, on: s.id==e.student_id,
   left_join: p in School.Affairs.Subject, on: p.id==e.subject_id,
   where: e.exam_id==^exam_id and k.semester_id==^semester_id,select: %{subject_code: p.code,exam_name: k.name,student_id: s.id, student_name: s.name,student_mark: e.mark})



if exam_mark != [] do
  


exam_name=exam_mark|>Enum.map(fn x -> x.exam_name end)|>Enum.uniq|>hd

all_mark=exam_mark |>Enum.group_by(fn x -> x.subject_code end)

   mark1=for item <- all_mark do

    subject_code=item|>elem(0)

    datas=item|>elem(1)

    for data <- datas do

    student_mark=data.student_mark

       grades=Repo.all(from g in School.Affairs.Grade)

       for grade <- grades do

        if student_mark >= grade.mix and student_mark <= grade.max do
          
          %{student_id: data.student_id,student_name: data.student_name,grade: grade.name,gpa: grade.gpa,subject_code: subject_code, student_mark: student_mark}

        end

         
       end


      
    end
   
   end|>List.flatten|>Enum.filter(fn x -> x != nil end)


   news=mark1|>Enum.group_by(fn x -> x.student_name end)


   z=for new <- news do


     total=new|>elem(1)|>Enum.map(fn x -> x.student_mark end)|>Enum.sum

           per= new|>elem(1)|>Enum.map(fn x -> x.student_mark end)|>Enum.count
          total_per=per *100 
     
      student_id=new|>elem(1)|>Enum.map(fn x -> x.student_id end)|>Enum.uniq|>hd

           a=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="A" end)  
           b=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="B" end)  
          c=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="C" end) 
           d=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="D" end) 
           e=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="E" end) 
           f=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="F" end)  
           g=new|>elem(1)|>Enum.map(fn x -> x.grade end)|>Enum.count(fn x -> x =="G" end)  

           total_gpa= new|>elem(1)|>Enum.map(fn x -> Decimal.to_float(x.gpa) end)|>Enum.sum 
            cgpa = (total_gpa/per)|>Float.round(2) 

      %{subject: new|>elem(1)|>Enum.sort_by(fn x -> x.subject_code end),name: new|>elem(0),student_id: student_id,total_mark: total,per: per, total_per: total_per, a: a ,b: b,c: c,d: d ,e: e,f: f,g: g, cgpa: cgpa}  
   end|>Enum.sort_by(fn x -> x.total_mark end)|>Enum.reverse



   mark=mark1|>Enum.group_by(fn x -> x.subject_code end)

    render(conn, "exam_ranking.html",z: z,exam_name: exam_name,mark: mark,mark1: mark1)

  else
    conn
     |> put_flash(:info, "Please Insert Exam Record First")
        |> redirect(to: class_path(conn, :index))


    end

  end



  def show(conn, %{"id" => id}) do
    exam = Affairs.get_exam!(id)
    render(conn, "show.html", exam: exam)
  end

  def edit(conn, %{"id" => id}) do
    exam = Affairs.get_exam!(id)
    changeset = Affairs.change_exam(exam)
    render(conn, "edit.html", exam: exam, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exam" => exam_params}) do
    exam = Affairs.get_exam!(id)

    case Affairs.update_exam(exam, exam_params) do
      {:ok, exam} ->
        conn
        |> put_flash(:info, "Exam updated successfully.")
        |> redirect(to: exam_path(conn, :show, exam))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", exam: exam, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exam = Affairs.get_exam!(id)
    {:ok, _exam} = Affairs.delete_exam(exam)

    conn
    |> put_flash(:info, "Exam deleted successfully.")
    |> redirect(to: exam_path(conn, :index))
  end
end
