defmodule School.Affairs.Segak do
  use Ecto.Schema
  import Ecto.Changeset

  schema "segak" do
    field(:class_id, :integer)
    field(:institution_id, :integer)
    field(:mark, :integer)
    field(:semester_id, :integer)
    field(:standard_id, :integer)
    field(:student_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(segak, attrs) do
    segak
    |> cast(attrs, [:student_id, :semester_id, :standard_id, :class_id, :mark, :institution_id])
    |> validate_required([
      :student_id,
      :semester_id,
      :standard_id,
      :class_id,
      :mark,
      :institution_id
    ])
  end
end
