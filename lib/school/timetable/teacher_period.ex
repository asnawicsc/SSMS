defmodule School.TimetableMaster.TeacherPeriod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teacher_period" do
    field(:activity, :string)
    field(:day, :string)
    field(:end_time, :time)
    field(:start_time, :time)
    field(:place, :string)
    field(:teacher_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(teacher_period, attrs) do
    teacher_period
    |> cast(attrs, [:place, :day, :start_time, :end_time, :activity, :teacher_id])
  end
end
