defmodule School.Affairs.TeacherAbsentReason do
  use Ecto.Schema
  import Ecto.Changeset


  schema "teacher_absent_reason" do
    field :absent_reason_id, :integer
    field :semester_id, :integer
    field :teacher_id, :integer

    timestamps()
  end

  @doc false
  def changeset(teacher_absent_reason, attrs) do
    teacher_absent_reason
    |> cast(attrs, [:teacher_id, :absent_reason_id, :semester_id])
    |> validate_required([:teacher_id, :absent_reason_id, :semester_id])
  end
end
