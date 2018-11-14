defmodule School.Affairs.Period do
  use Ecto.Schema
  import Ecto.Changeset

  schema "period" do
    field(:day, :string)
    field(:end_time, :time)
    field(:start_time, :time)
    field(:subject_id, :integer)
    field(:teacher_id, :integer)
    field(:class_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [:class_id, :start_time, :end_time, :day, :subject_id, :teacher_id])
  end
end
