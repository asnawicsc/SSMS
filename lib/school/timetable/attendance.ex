defmodule School.TimetableMaster.Attendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendance" do
    field(:attendance_date, :date)
    field(:class_id, :integer)
    field(:institution_id, :integer)
    field(:mark_by, :string)
    field(:semester_id, :integer)
    field(:student_id, :string, default: "")

    timestamps()
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [
      :institution_id,
      :class_id,
      :student_id,
      :semester_id,
      :attendance_date,
      :mark_by
    ])
    |> validate_required([:institution_id, :class_id, :semester_id, :attendance_date])
  end
end
