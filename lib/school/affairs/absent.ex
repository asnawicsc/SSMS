defmodule School.Affairs.Absent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "absent" do
    field(:absent_date, :date)
    field(:reason, :string)
    field(:institution_id, :integer)
    field(:class_id, :integer)
    field(:student_id, :string)
    field(:semester_id, :integer)
    field(:teacher_id, :string)

    timestamps()
  end

  @doc false
  def changeset(absent, attrs) do
    absent
    |> cast(attrs, [
      :institution_id,
      :class_id,
      :student_id,
      :semester_id,
      :reason,
      :absent_date,
      :teacher_id
    ])
    |> validate_required([
      :institution_id,
      :class_id,
      :semester_id,
      :reason,
      :absent_date
    ])
  end
end
