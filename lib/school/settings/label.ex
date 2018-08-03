defmodule School.Settings.Label do
  use Ecto.Schema
  import Ecto.Changeset


  schema "labels" do
    field :bm, :string
    field :cn, :string
    field :en, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(label, attrs) do
    label
    |> cast(attrs, [:name, :en, :cn, :bm])
    |> validate_required([:name, :en, :cn, :bm])
  end
end
