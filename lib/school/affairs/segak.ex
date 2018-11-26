defmodule School.Affairs.Segak do
  use Ecto.Schema
  import Ecto.Changeset


  schema "segak" do
    field :class_id, :string
    field :institution_id, :string
    field :mark, :string
    field :semester_id, :string
    field :standard_id, :string
    field :student_id, :string

    timestamps()
  end

  @doc false
  def changeset(segak, attrs) do
    segak
    |> cast(attrs, [:student_id, :semester_id, :standard_id, :class_id, :mark, :institution_id])
    |> validate_required([:student_id, :semester_id, :standard_id, :class_id, :mark, :institution_id])
  end
end
