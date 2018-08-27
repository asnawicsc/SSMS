defmodule School.Affairs.SubjectTeachClass do
  use Ecto.Schema
  import Ecto.Changeset


  schema "subject_teach_class" do
    field :class_id, :integer
    field :standard_id, :integer
    field :subject_id, :integer
    field :teacher_id, :integer

    timestamps()
  end

  @doc false
  def changeset(subject_teach_class, attrs) do
    subject_teach_class
    |> cast(attrs, [:standard_id, :subject_id, :teacher_id, :class_id])
    |> validate_required([:standard_id, :subject_id, :teacher_id, :class_id])
  end
end
