defmodule School.Affairs.Holiday do
  use Ecto.Schema
  import Ecto.Changeset


  schema "holiday" do
    field :date, :date
    field :description, :string
    field :institution_id, :integer
    field :semester_id, :integer

    timestamps()
  end

  @doc false
  def changeset(holiday, attrs) do
    holiday
    |> cast(attrs, [:date, :description, :semester_id, :institution_id])
    |> validate_required([:date, :description, :semester_id, :institution_id])
  end
end
