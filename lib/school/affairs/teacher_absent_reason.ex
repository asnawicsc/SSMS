defmodule School.Affairs.TeacherAbsentReason do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teacher_absent_reason" do
    field(:absent_reason, :string)
    field(:institution_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(teacher_absent_reason, attrs) do
    teacher_absent_reason
    |> cast(attrs, [:absent_reason, :institution_id])
    |> validate_required([:absent_reason, :institution_id])
  end
end
