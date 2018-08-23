defmodule School.Affairs.CoGrade do
  use Ecto.Schema
  import Ecto.Changeset


  schema "co_grade" do
    field :gpa, :decimal
    field :max, :integer
    field :min, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(co_grade, attrs) do
    co_grade
    |> cast(attrs, [:name, :max, :min, :gpa])
    |> validate_required([:name, :max, :min, :gpa])
  end
end
