defmodule School.Affairs.Semester do
  use Ecto.Schema
  import Ecto.Changeset


  schema "semesters" do
    field :end_date, :date
    field :holiday_end, :date
    field :holiday_start, :date
    field :school_days, :integer
    field :start_date, :date

    timestamps()
  end

  @doc false
  def changeset(semester, attrs) do
    semester
    |> cast(attrs, [:start_date, :end_date, :holiday_start, :holiday_end, :school_days])
    |> validate_required([:start_date, :end_date, :holiday_start, :holiday_end])
  end
end
