defmodule School.Affairs.ExamMark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exam_mark" do
    field(:class_id, :integer)
    field(:exam_id, :integer)
    field(:mark, :integer)
    field(:grade, :string)
    field(:student_id, :integer)
    field(:subject_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(exam_mark, attrs) do
    exam_mark
    |> cast(attrs, [:class_id, :exam_id, :mark, :grade, :subject_id, :student_id])
    |> validate_required([:class_id, :exam_id, :subject_id, :student_id])
  end
end
