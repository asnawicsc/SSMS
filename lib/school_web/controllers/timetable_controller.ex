defmodule SchoolWeb.TimetableController do
  use SchoolWeb, :controller
  require IEx

  alias School.Affairs
  alias School.Affairs.Timetable
    alias School.Affairs.Subject

  def index(conn, _params) do
    timetable = Affairs.list_timetable()
    render(conn, "index.html", timetable: timetable)
  end

  def new(conn, _params) do
    changeset = Affairs.change_timetable(%Timetable{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"timetable" => timetable_params}) do
    case Affairs.create_timetable(timetable_params) do
      {:ok, timetable} ->
        conn
        |> put_flash(:info, "Timetable created successfully.")
        |> redirect(to: timetable_path(conn, :show, timetable))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    timetable = Affairs.get_timetable!(id)
    render(conn, "show.html", timetable: timetable)
  end

  def edit(conn, %{"id" => id}) do
    timetable = Affairs.get_timetable!(id)
    changeset = Affairs.change_timetable(timetable)
    render(conn, "edit.html", timetable: timetable, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timetable" => timetable_params}) do
    timetable = Affairs.get_timetable!(id)

    case Affairs.update_timetable(timetable, timetable_params) do
      {:ok, timetable} ->
        conn
        |> put_flash(:info, "Timetable updated successfully.")
        |> redirect(to: timetable_path(conn, :show, timetable))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", timetable: timetable, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    timetable = Affairs.get_timetable!(id)
    {:ok, _timetable} = Affairs.delete_timetable(timetable)

    conn
    |> put_flash(:info, "Timetable deleted successfully.")
    |> redirect(to: timetable_path(conn, :index))
  end

   def generated_timetable(conn, params) do
     changeset = Affairs.change_timetable(%Timetable{})
    class_id=params["id"]

    class=School.Affairs.get_class!(class_id)

 
   period=Repo.all(from p in School.Affairs.Period,
    left_join: s in School.Affairs.Subject, on: s.id==p.subject_id,
    left_join: t in School.Affairs.Teacher, on: t.id==p.teacher_id,
    left_join: d in School.Affairs.Day, on: d.name==p.day,
    where: p.class_id==^class_id,select: %{day_name: d.name,day_number: d.number,end_time: p.end_time,start_time: p.start_time,t_name: t.name,s_code: s.code})

   all=for item <- period do
      e=item.end_time.hour  
      s=item.start_time.hour 

       if  e == 0 do 

          e= 12
      end

      if  s == 0 do

          s= 12
      end 

      %{day_name: item.day_name,day_number: item.day_number,end_time: e,start_time: s,t_name: item.t_name,s_code: item.s_code}
    
   end|>Enum.group_by(fn x -> x.day_number end)

   time_period=Repo.all(from tp in School.Affairs.TimePeriod)|>Enum.sort_by(fn x -> x.time_start end)

    render(conn, "generated_timetable.html",changeset: changeset,time_period: time_period,class: class,period: all)
  end
end
