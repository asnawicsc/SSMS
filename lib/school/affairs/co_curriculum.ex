defmodule School.Affairs.CoCurriculum do
  use Ecto.Schema
  import Ecto.Changeset


  schema "cocurriculum" do
    field :code, :string
    field :description, :string
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(co_curriculum, attrs) do
    co_curriculum
    |> cast(attrs, [:institution_id, :code, :description])
    |> validate_required([:institution_id ,:code, :description])
  end
end
