defmodule School.Affairs.ListRank do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list_rank" do
    field(:mark, :integer)
    field(:name, :string)
    field(:institution_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(list_rank, attrs) do
    list_rank
    |> cast(attrs, [:name, :mark, :institution_id])
    |> validate_required([:name, :mark, :institution_id])
  end
end
