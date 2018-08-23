defmodule School.Affairs.HemJob do
  use Ecto.Schema
  import Ecto.Changeset


  schema "hem_job" do
    field :cdesc, :string
    field :code, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(hem_job, attrs) do
    hem_job
    |> cast(attrs, [:code, :description, :cdesc])
  end
end
