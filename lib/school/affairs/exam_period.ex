defmodule School.Affairs.ExamPeriod do
  use Ecto.Schema
  import Ecto.Changeset


  schema "examperiod" do
    field :end_date, :naive_datetime
    field :exam_id, :integer
    field :start_date, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(exam_period, attrs) do
    exam_period
    |> cast(attrs, [:start_date, :end_date, :exam_id])
    |> validate_required([:start_date, :end_date, :exam_id])
  end
end
