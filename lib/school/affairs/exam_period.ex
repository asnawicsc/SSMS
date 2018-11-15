defmodule School.Affairs.ExamPeriod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "examperiod" do
    field(:end_date, :utc_datetime)
    field(:exam_id, :integer)
    field(:start_date, :utc_datetime)
    field(:institution_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(exam_period, attrs) do
    exam_period
    |> cast(attrs, [:start_date, :end_date, :exam_id, :institution_id])
  end
end
