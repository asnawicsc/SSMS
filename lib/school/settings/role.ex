defmodule School.Settings.Role do
  use Ecto.Schema
  import Ecto.Changeset


  schema "role" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
