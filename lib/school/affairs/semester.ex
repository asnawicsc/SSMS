defmodule School.Affairs.Semester do
  use Ecto.Schema
  import Ecto.Changeset

  schema "semesters" do
    field(:end_date, :date)
    field(:holiday_end, :date)
    field(:holiday_start, :date)
    field(:school_days, :integer)
    field(:start_date, :date)
    field(:institution_id, :integer)
    field(:next_semester_id, :integer)
    field(:sem, :integer)
    field(:year, :integer)

    timestamps()
  end

  @doc false
  def changeset(semester, attrs) do
    semester
    |> cast(attrs, [
      :start_date,
      :end_date,
      :holiday_start,
      :holiday_end,
      :school_days,
      :institution_id,
      :next_semester_id,
      :year,
      :sem
    ])
    |> validate_required([:start_date, :end_date, :year, :sem, :institution_id])
  end
end
