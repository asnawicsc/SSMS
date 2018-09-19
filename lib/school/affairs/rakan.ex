defmodule School.Affairs.Rakan do
  use Ecto.Schema
  import Ecto.Changeset


  schema "rakan" do
    field :max, :integer
    field :min, :integer
    field :prize, :string
    field :standard_id, :integer
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(rakan, attrs) do
    rakan
    |> cast(attrs, [:institution_id, :prize, :min, :max, :standard_id])
    |> validate_required([:institution_id, :prize, :min, :max, :standard_id])
  end
end
