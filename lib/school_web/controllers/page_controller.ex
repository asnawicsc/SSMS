defmodule SchoolWeb.PageController do
  use SchoolWeb, :controller
require IEx
  def index(conn, _params) do
  	current_sem = Repo.all(from s in School.Affairs.Semester, where: s.end_date > ^Timex.today and s.start_date < ^Timex.today )

  	if current_sem != [] do
  	  current_sem = hd(current_sem)
  	else
  		current_sem = %{start_date: "Not set", end_date: "Not set"}
  	end
    render conn, "index.html", current_sem: current_sem
  end
end
