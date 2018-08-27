defmodule SchoolWeb.TeacherPeriodController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.TeacherPeriod

  require IEx

  def index(conn, _params) do
    teacher_period = Affairs.list_teacher_period()
    render(conn, "index.html", teacher_period: teacher_period)
  end

  def new(conn, _params) do
    changeset = Affairs.change_teacher_period(%TeacherPeriod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create_teacher_period(conn, params) do

    place=params["place"]
    activity=params["activity"]
    day=params["day"]
    end_time=params["end_time"]|>String.reverse
    start_time=params["start_time"]|>String.reverse
    teacher=params["teacher"]

    a="00:"
    new_end_time=a<>end_time|>String.reverse|>Time.from_iso8601!()
    new_start_time=a<>start_time|>String.reverse|>Time.from_iso8601!()

    n_time=new_start_time.hour
      n_sm=new_start_time.minute
    e_time=new_end_time.hour
      n_em=new_start_time.minute

     if  n_time == 0 do 

          n_time= 12
      end

      if  e_time == 0 do

          e_time= 12
      end 



    teacher=Repo.get_by(School.Affairs.Teacher,code: teacher)

    params=%{day: day, end_time: new_end_time, start_time: new_start_time,teacher_id: teacher.id,place: place,activity: activity}



    period_class=Repo.all(from p in School.Affairs.Period, where: p.teacher_id ==^teacher.id and p.day ==^day)


      all=for item <- period_class do
      e=item.end_time.hour  
      s=item.start_time.hour 
        em=item.end_time.minute  
      sm=item.start_time.minute 

       if  e == 0 do 

          e= 12
      end

      if  s == 0 do

          s= 12
      end 

      %{end_time: e,start_time: s,start_minute: sm,end_minute: em}
    
   end

   a=all|>Enum.filter(fn x -> x.start_time >= n_time and x.start_time <= e_time and x.start_minute >= n_sm and x.start_minute <= n_em end)


   b=a|>Enum.count



    if b == 0 do



   changeset = Affairs.change_teacher_period(%TeacherPeriod{})

     case Affairs.create_teacher_period(params) do
      {:ok, teacher_period} ->
        conn
        |> put_flash(:info, "Teacher Period created successfully.")
        |> redirect(to: teacher_period_path(conn, :show, teacher_period))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
        end

      else

         conn
        |> put_flash(:info, "That slot already been taken,please refer to period table.")
        |> redirect(to: teacher_period_path(conn, :index))
   
    end


 
   


  end

  def create(conn, %{"teacher_period" => teacher_period_params}) do
    case Affairs.create_teacher_period(teacher_period_params) do
      {:ok, teacher_period} ->
        conn
        |> put_flash(:info, "Teacher period created successfully.")
        |> redirect(to: teacher_period_path(conn, :show, teacher_period))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher_period = Affairs.get_teacher_period!(id)
    render(conn, "show.html", teacher_period: teacher_period)
  end

  def edit(conn, %{"id" => id}) do
    teacher_period = Affairs.get_teacher_period!(id)

    teacher=Repo.get_by(School.Affairs.Teacher,id: teacher_period.teacher_id)
    start_time=teacher_period.start_time|>Time.to_string|>String.split_at(5)|>elem(0)
    end_time=teacher_period.end_time|>Time.to_string|>String.split_at(5)|>elem(0)

    changeset = Affairs.change_teacher_period(teacher_period)
    render(conn, "edit.html", teacher_period: teacher_period, changeset: changeset,teacher: teacher,start_time: start_time,end_time: end_time)
  end

  def update(conn, %{"id" => id, "teacher_period" => teacher_period_params}) do
    teacher_period = Affairs.get_teacher_period!(id)

    case Affairs.update_teacher_period(teacher_period, teacher_period_params) do
      {:ok, teacher_period} ->
        conn
        |> put_flash(:info, "Teacher period updated successfully.")
        |> redirect(to: teacher_period_path(conn, :show, teacher_period))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", teacher_period: teacher_period, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher_period = Affairs.get_teacher_period!(id)
    {:ok, _teacher_period} = Affairs.delete_teacher_period(teacher_period)

    conn
    |> put_flash(:info, "Teacher period deleted successfully.")
    |> redirect(to: teacher_period_path(conn, :index))
  end
end
