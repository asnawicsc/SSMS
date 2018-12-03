defmodule School.Affairs.Subject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subject" do
    field(:cdesc, :string)
    field(:code, :string)
    field(:description, :string)
    field(:sysdef, :integer)
    field(:institution_id, :integer)
    field(:color, :string)
    has_many(:period, School.Affairs.Period)
    timestamps()
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:color, :institution_id, :code, :description, :cdesc, :sysdef])
  end
end
