defmodule SchoolWeb.PageController do
  use SchoolWeb, :controller

  def index(conn, _params) do
  	current_sem = Repo.all(from s in School.Affairs.Semester, order_by: [desc: s.start_date]) 
  	if current_sem != [] do
  	  current_sem = hd(current_sem)
  	else
  		current_sem = %{start_date: "Not set", end_date: "Not set"}
  	end
    render conn, "index.html", current_sem: current_sem
  end
end
