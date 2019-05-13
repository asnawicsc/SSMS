defmodule School.Affairs.Coco_Rank do
  use Ecto.Schema
  import Ecto.Changeset


  schema "coco_ranks" do
    field :rank, :string
    field :sub_category, :string

    timestamps()
  end

  @doc false
  def changeset(coco__rank, attrs) do
    coco__rank
    |> cast(attrs, [:sub_category, :rank])
    |> validate_required([:sub_category, :rank])
  end
end
