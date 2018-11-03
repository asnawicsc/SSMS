defmodule School.TimetableMaster.Timetable do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timetable" do
    field(:class_id, :integer)
    field(:institution_id, :integer)
    field(:level_id, :integer)
    field(:period_id, :integer)
    field(:semester_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(timetable, attrs) do
    timetable
    |> cast(attrs, [:class_id, :institution_id, :level_id, :period_id, :semester_id])
    |> validate_required([:class_id, :institution_id, :level_id, :period_id, :semester_id])
  end
end
