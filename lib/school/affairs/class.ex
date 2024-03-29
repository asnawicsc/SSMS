defmodule School.Affairs.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field(:name, :string)
    field(:remarks, :string)
    field(:institution_id, :integer)
    field(:level_id, :integer)
    field(:teacher_id, :integer)
    field(:next_class, :string)
    field(:is_delete, :integer, default: 0)

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [
      :teacher_id,
      :level_id,
      :institution_id,
      :name,
      :remarks,
      :next_class,
      :is_delete
    ])
    |> validate_required([:name, :institution_id])
  end
end
