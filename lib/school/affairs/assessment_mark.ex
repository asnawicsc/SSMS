defmodule School.Affairs.AssessmentMark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assessment_mark" do
    field(:class_id, :integer)
    field(:institution_id, :integer)
    field(:semester_id, :integer)
    field(:standard_id, :integer)
    field(:student_id, :integer)
    field(:subject_id, :integer)
    field(:assessment_subject_id, :integer)
    field(:assessment_subject_level, :string)

    timestamps()
  end

  @doc false
  def changeset(assessment_mark, attrs) do
    assessment_mark
    |> cast(attrs, [
      :institution_id,
      :semester_id,
      :subject_id,
      :standard_id,
      :class_id,
      :student_id,
      :assessment_subject_id,
      :assessment_subject_level
    ])
    |> validate_required([
      :institution_id,
      :semester_id,
      :subject_id,
      :standard_id,
      :class_id,
      :student_id,
      :assessment_subject_id,
      :assessment_subject_level
    ])
  end
end
