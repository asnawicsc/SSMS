defmodule School.Affairs.StandardSubject do
  use Ecto.Schema
  import Ecto.Changeset


  schema "standard_subject" do
    field :semester_id, :integer
    field :standard_id, :integer
    field :subject_id, :integer
    field :year, :string
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(standard_subject, attrs) do
    standard_subject
    |> cast(attrs, [:institution_id, :year, :semester_id, :standard_id, :subject_id])
    |> validate_required([:institution_id, :year, :semester_id, :standard_id, :subject_id])
  end
end
