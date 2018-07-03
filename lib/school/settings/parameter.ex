defmodule School.Settings.Parameter do
  use Ecto.Schema
  import Ecto.Changeset


  schema "parameters" do
    field :blood_type, :binary
    field :career, :binary
    field :nationality, :binary
    field :oku, :binary
    field :race, :binary
    field :religion, :binary
    field :sickness, :binary
    field :transport, :binary
    field :school_id, :integer

    timestamps()
  end

  @doc false
  def changeset(parameter, attrs) do
    parameter
    |> cast(attrs, [:school_id, :nationality, :race, :religion, :blood_type, :transport, :sickness, :career, :oku])

  end
end
