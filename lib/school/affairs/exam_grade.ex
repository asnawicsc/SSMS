defmodule School.Affairs.ExamGrade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exam_grade" do
    field(:gpa, :decimal)
    field(:institution_id, :integer)
    field(:max, :integer)
    field(:min, :integer)
    field(:name, :string)
    field(:exam_master_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(exam_grade, attrs) do
    exam_grade
    |> cast(attrs, [:name, :min, :max, :gpa, :institution_id, :exam_master_id])
    |> validate_required([:name, :min, :max, :gpa, :institution_id, :exam_master_id])
  end
end
