defmodule School.Affairs.Subject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subject" do
    field(:cdesc, :string)
    field(:code, :string)
    field(:description, :string)
    field(:timetable_description, :string)
    field(:timetable_code, :string)
    field(:sysdef, :integer)
    field(:institution_id, :integer)
    field(:color, :string)
    has_many(:period, School.Affairs.Period)
    timestamps()
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [
      :timetable_description,
      :timetable_code,
      :color,
      :institution_id,
      :code,
      :description,
      :cdesc,
      :sysdef
    ])
  end
end
