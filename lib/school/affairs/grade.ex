defmodule School.Affairs.Grade do
  use Ecto.Schema
  import Ecto.Changeset


  schema "grade" do
    field :max, :integer
    field :mix, :integer
    field :name, :string
    field :gpa, :decimal
     field :standard_id, :integer

    timestamps()
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:standard_id,:name, :max, :mix,:gpa])
    |> validate_required([:standard_id,:name, :max, :mix,:gpa])
  end
end
