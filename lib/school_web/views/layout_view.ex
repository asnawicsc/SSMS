defmodule SchoolWeb.LayoutView do
  use SchoolWeb, :view

  def my_time(time) when time != nil do
    Timex.format!(Timex.shift(time, hours: 8), "%Y-%m-%d %I:%M %P", :strftime)
  end
end
