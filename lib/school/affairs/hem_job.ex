defmodule School.Affairs.HemJob do
  use Ecto.Schema
  import Ecto.Changeset


  schema "hem_job" do
    field :cdesc, :string
    field :code, :string
    field :description, :string
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(hem_job, attrs) do
    hem_job
    |> cast(attrs, [:institution_id, :code, :description, :cdesc])
  end
end
