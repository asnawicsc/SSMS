defmodule School.Affairs.ProjectNilam do
  use Ecto.Schema
  import Ecto.Changeset


  schema "project_nilam" do
    field :below_satisfy, :integer
    field :count_page, :integer
    field :import_from_library, :integer
    field :member_reading_quantity, :integer
    field :page, :integer
    field :standard_id, :integer

    timestamps()
  end

  @doc false
  def changeset(project_nilam, attrs) do
    project_nilam
    |> cast(attrs, [:below_satisfy, :member_reading_quantity, :page, :import_from_library, :count_page, :standard_id])
    |> validate_required([:below_satisfy, :member_reading_quantity, :page,:standard_id])
  end
end
