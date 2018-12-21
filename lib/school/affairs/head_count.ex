defmodule School.Affairs.HeadCount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "head_counts" do
    field(:class_id, :integer)
    field(:student_id, :integer)
    field(:subject_id, :integer)
    field(:targer_mark, :integer)
    field(:institution_id, :integer)
    field(:semester_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(head_count, attrs) do
    head_count
    |> cast(attrs, [
      :institution_id,
      :semester_id,
      :class_id,
      :subject_id,
      :student_id,
      :targer_mark
    ])
    |> validate_required([
      :class_id,
      :subject_id,
      :student_id,
      :targer_mark,
      :institution_id,
      :semester_id
    ])
  end
end
