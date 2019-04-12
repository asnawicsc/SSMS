defmodule School.Affairs.ExamAttendance do
  use Ecto.Schema
  import Ecto.Changeset


  schema "exam_attendance" do
    field :class_id, :integer
    field :exam_id, :integer
    field :exam_master_id, :integer
    field :institution_id, :integer
    field :semester_id, :integer
    field :student_id, :integer
    field :subject_id, :integer

    timestamps()
  end

  @doc false
  def changeset(exam_attendance, attrs) do
    exam_attendance
    |> cast(attrs, [:student_id, :class_id, :exam_id, :exam_master_id, :subject_id, :semester_id, :institution_id])
    |> validate_required([:student_id, :class_id, :exam_id, :exam_master_id, :subject_id, :semester_id, :institution_id])
  end
end
