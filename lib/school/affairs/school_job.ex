defmodule School.Affairs.SchoolJob do
  use Ecto.Schema
  import Ecto.Changeset


  schema "school_job" do
    field :cdesc, :string
    field :code, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(school_job, attrs) do
    school_job
    |> cast(attrs, [:code, :description, :cdesc])
  end
end
