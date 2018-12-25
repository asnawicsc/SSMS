defmodule School.Affairs.Ehomework do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ehehomeworks" do
    field(:class_id, :integer)
    field(:end_date, :date)
    field(:semester_id, :integer)
    field(:start_date, :date)
    field(:subject_id, :integer)
    field(:desc, :binary)

    timestamps()
  end

  @doc false
  def changeset(ehomework, attrs) do
    ehomework
    |> cast(attrs, [:subject_id, :start_date, :end_date, :semester_id, :class_id, :desc])
    |> validate_required([:subject_id, :start_date, :end_date, :semester_id, :class_id, :desc])
  end
end
