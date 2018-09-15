defmodule SchoolWeb.PeriodController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Period
  alias School.Affairs.Class
  alias School.Affairs.Day
  alias School.Affairs.Teacher
  alias School.Affairs.Subject
  require IEx

  def index(conn, _params) do


    period = Affairs.list_period()
    render(conn, "index.html", period: period)
  end

  def new(conn, _params) do
    changeset = Affairs.change_period(%Period{})
    render(conn, "new.html", changeset: changeset)
  end

    def create_period(conn, params) do
    class_name=params["class"]
    subject=params["subject"]
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


    subject=Repo.get_by(Subject,code: subject)
    class=Repo.get_by(Class,name: class_name)
    teacher=Repo.get_by(Teacher,code: teacher)

    params=%{day: day, end_time: new_end_time, start_time: new_start_time,teacher_id: teacher.id,class_id: class.id,subject_id: subject.id}



    period_class=Repo.all(from p in Period, where: p.class_id ==^class.id and p.day ==^day)


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



   changeset = Affairs.change_period(%Period{})


     case Affairs.create_period(params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period created successfully.")
         |> redirect(to: subject_path(conn, :standard_setting))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
        end

      else

         conn
        |> put_flash(:info, "That slot already been taken,please refer to period table.")
        |> redirect(to: subject_path(conn, :standard_setting))
   
    end


 
   


  end

  def create(conn, %{"period" => period_params}) do
    case Affairs.create_period(period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period created successfully.")
        |> redirect(to: period_path(conn, :show, period))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    period = Affairs.get_period!(id)
    render(conn, "show.html", period: period)
  end

  def edit(conn, %{"id" => id}) do
    period = Affairs.get_period!(id)

    subject=Repo.get_by(Subject,id: period.subject_id)
    class=Repo.get_by(Class,id: period.class_id)
    teacher=Repo.get_by(Teacher,id: period.teacher_id)

    start_time=period.start_time|>Time.to_string|>String.split_at(5)|>elem(0)
    end_time=period.end_time|>Time.to_string|>String.split_at(5)|>elem(0)


    changeset = Affairs.change_period(period)
    render(conn, "edit.html", period: period, changeset: changeset,start_time: start_time,end_time: end_time,subject: subject,class: class,teacher: teacher)
  end

  def update(conn, %{"id" => id, "period" => period_params}) do
    period = Affairs.get_period!(id)

    case Affairs.update_period(period, period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period updated successfully.")
        |> redirect(to: period_path(conn, :show, period))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", period: period, changeset: changeset)
    end
  end

    def update_period(conn, params) do
 
      id= params["id"]
      class_name=params["period"]["class"]
      day=params["period"]["day"]
      end_time=params["period"]["end_time"]|>String.reverse
      start_time=params["period"]["start_time"]|>String.reverse
      subject=params["period"]["subject"]
      teacher=params["period"]["teacher"]

          a="00:"
    new_end_time=a<>end_time|>String.reverse|>Time.from_iso8601!()
    new_start_time=a<>start_time|>String.reverse|>Time.from_iso8601!()

        n_time=new_start_time.hour
      n_sm=new_start_time.minute
    e_time=new_end_time.hour
      n_em=new_start_time.minute

    subject=Repo.get_by(Subject,code: subject)
    class=Repo.get_by(Class,name: class_name)
    teacher=Repo.get_by(Teacher,code: teacher)

    period_params=%{class_id: class.id,day: day,start_time: new_start_time,end_time: new_end_time,subject_id: subject.id,teacher_id: teacher.id}

    period = Affairs.get_period!(id)




    period_class=Repo.all(from p in Period, where: p.class_id ==^class.id and p.day ==^day)|>Enum.reject(fn x -> x.id == period.id end)

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




      changeset = Affairs.change_period(period)
      case Affairs.update_period(period, period_params) do
        {:ok, period} ->
          conn
          |> put_flash(:info, "Period updated successfully.")
          |> redirect(to: period_path(conn, :show, period))
       
      end


  else

         conn
        |> put_flash(:info, "That slot already been taken,please refer to period table.")
        |> redirect(to: period_path(conn, :index))
   
    end

  end

  def delete(conn, %{"id" => id}) do
    period = Affairs.get_period!(id)
    {:ok, _period} = Affairs.delete_period(period)

    conn
    |> put_flash(:info, "Period deleted successfully.")
    |> redirect(to: period_path(conn, :index))
  end
end
