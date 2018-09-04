defmodule School.Affairs.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do

    field :name, :string
    field :remarks, :string
    field :institution_id, :integer
  field :level_id, :integer
  field :teacher_id, :integer

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:teacher_id,:level_id, :institution_id, :name, :remarks])
    |> validate_required([:name, :institution_id, :level_id])
  end
end
