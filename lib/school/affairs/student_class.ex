defmodule School.Affairs.StudentClass do
  use Ecto.Schema
  import Ecto.Changeset

  schema "student_classes" do
    field(:class_id, :integer)
    field(:institute_id, :integer)
    field(:level_id, :integer)
    field(:semester_id, :integer)
    field(:sudent_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(student_class, attrs) do
    student_class
    |> cast(attrs, [:institute_id, :level_id, :semester_id, :class_id, :sudent_id])
    |> validate_required([:institute_id, :semester_id, :class_id, :sudent_id])
    |> unique_constraint(:sudent_id, name: :index_all)
  end
end
