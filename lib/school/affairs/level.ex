defmodule School.Affairs.Level do
  use Ecto.Schema
  import Ecto.Changeset


  schema "levels" do
    field :name, :string
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(level, attrs) do
    level
    |> cast(attrs, [:institution_id, :name])
    |> validate_required([:institution_id, :name])
  end
end
