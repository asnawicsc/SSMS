defmodule School.Affairs.CoCurriculum do
  use Ecto.Schema
  import Ecto.Changeset


  schema "cocurriculum" do
    field :code, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(co_curriculum, attrs) do
    co_curriculum
    |> cast(attrs, [:code, :description])
    |> validate_required([:code, :description])
  end
end
