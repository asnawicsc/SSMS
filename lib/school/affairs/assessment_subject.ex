defmodule School.Affairs.AssessmentSubject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assessment_subject" do
    field(:institution_id, :integer)
    field(:semester_id, :integer)
    field(:standard_id, :integer)
    field(:subject_id, :integer)
    field(:level1, :string)
    field(:level2, :string)
    field(:level3, :string)
    field(:level4, :string)
    field(:level5, :string)
    field(:level6, :string)

    timestamps()
  end

  @doc false
  def changeset(assessment_subject, attrs) do
    assessment_subject
    |> cast(attrs, [
      :level1,
      :level2,
      :level3,
      :level4,
      :level5,
      :level6,
      :institution_id,
      :semester_id,
      :subject_id,
      :standard_id
    ])
    |> validate_required([:institution_id, :semester_id, :subject_id, :standard_id])
  end
end
