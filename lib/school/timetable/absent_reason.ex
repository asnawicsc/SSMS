defmodule School.TimetableMaster.AbsentReason do
  use Ecto.Schema
  import Ecto.Changeset

  schema "absent_reason" do
    field(:code, :string)
    field(:description, :string)
    field(:type, :string)
    field(:institution_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(absent_reason, attrs) do
    absent_reason
    |> cast(attrs, [:institution_id, :code, :description, :type])
  end
end
