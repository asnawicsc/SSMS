defmodule School.Affairs.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grade" do
    field(:max, :integer)
    field(:mix, :integer)
    field(:name, :string)
    field(:gpa, :decimal)
    field(:standard_id, :integer)
    field(:institution_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:institution_id,:standard_id, :name, :max, :mix, :gpa])
    |> validate_required([:institution_id,:standard_id, :name, :max, :mix, :gpa])
  end
end
