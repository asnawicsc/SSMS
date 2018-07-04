defmodule School.Affairs.Class do
  use Ecto.Schema
  import Ecto.Changeset


  schema "classes" do
    field :name, :string
    field :remarks, :string

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :remarks])
    |> validate_required([:name, :remarks])
  end
end
