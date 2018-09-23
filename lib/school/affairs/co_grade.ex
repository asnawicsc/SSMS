defmodule School.Affairs.CoGrade do
  use Ecto.Schema
  import Ecto.Changeset


  schema "co_grade" do
    field :gpa, :decimal
    field :max, :integer
    field :min, :integer
    field :name, :string
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(co_grade, attrs) do
    co_grade
    |> cast(attrs, [:institution_id, :name, :max, :min, :gpa])
    |> validate_required([:institution_id, :name, :max, :min, :gpa])
  end
end
