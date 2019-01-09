defmodule School.Affairs.RulesBreak do
  use Ecto.Schema
  import Ecto.Changeset


  schema "rules_break" do
    field :institution_id, :integer
    field :level, :integer
    field :remark, :string

    timestamps()
  end

  @doc false
  def changeset(rules_break, attrs) do
    rules_break
    |> cast(attrs, [:institution_id, :level, :remark])
    |> validate_required([:institution_id, :level, :remark])
  end
end
