defmodule School.Affairs.ExamMark do
  use Ecto.Schema
  import Ecto.Changeset


  schema "exam_mark" do
    field :class_id, :integer
    field :exam_id, :integer
    field :mark, :integer
    field :student_id, :integer
    field :subject_id, :integer

    timestamps()
  end

  @doc false
  def changeset(exam_mark, attrs) do
    exam_mark
    |> cast(attrs, [:class_id, :exam_id, :mark, :subject_id, :student_id])
    |> validate_required([:class_id, :exam_id, :mark, :subject_id, :student_id])
  end
end
