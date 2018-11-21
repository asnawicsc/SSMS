defmodule SchoolWeb.PeriodView do
  use SchoolWeb, :view

  def my_time(time) do
    if time != nil do
      Timex.format!(Timex.shift(time, hours: 8), "%Y-%m-%d %H:%M ", :strftime)
    else
      ""
    end
  end
end
