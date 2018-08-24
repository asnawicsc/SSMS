defmodule School.Affairs.Rakan do
  use Ecto.Schema
  import Ecto.Changeset


  schema "rakan" do
    field :max, :integer
    field :min, :integer
    field :prize, :string
    field :standard_id, :integer

    timestamps()
  end

  @doc false
  def changeset(rakan, attrs) do
    rakan
    |> cast(attrs, [:prize, :min, :max, :standard_id])
    |> validate_required([:prize, :min, :max, :standard_id])
  end
end
