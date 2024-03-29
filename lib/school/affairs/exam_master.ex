defmodule School.Affairs.ExamMaster do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exam_master" do
    field(:level_id, :integer)
    field(:name, :string)
    field(:semester_id, :integer)
    field(:year, :string)
    field(:institution_id, :integer)
    field(:exam_no, :integer)

    timestamps()
  end

  @doc false
  def changeset(exam_master, attrs) do
    exam_master
    |> cast(attrs, [:exam_no, :institution_id, :name, :semester_id, :level_id])
    |> validate_required([:exam_no, :institution_id, :name, :semester_id, :level_id])
  end
end
