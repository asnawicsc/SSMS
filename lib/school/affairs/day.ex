defmodule School.Affairs.Day do
  use Ecto.Schema
  import Ecto.Changeset


  schema "day" do
    field :name, :string
    field :number, :integer

    timestamps()
  end

  @doc false
  def changeset(day, attrs) do
    day
    |> cast(attrs, [:name,:number])
  end
end
