defmodule School.Affairs.Jauhari do
  use Ecto.Schema
  import Ecto.Changeset


  schema "jauhari" do
    field :max, :integer
    field :min, :integer
    field :prize, :string
    field :standard_id, :integer

    timestamps()
  end

  @doc false
  def changeset(jauhari, attrs) do
    jauhari
    |> cast(attrs, [:standard_id,:prize, :min, :max])
    |> validate_required([:standard_id,:prize, :min, :max])
  end
end
