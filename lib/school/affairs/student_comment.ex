defmodule School.Affairs.StudentComment do
  use Ecto.Schema
  import Ecto.Changeset


  schema "student_comment" do
    field :class_id, :integer
    field :comment1, :string
    field :comment2, :string
    field :comment3, :string
    field :semester_id, :integer
    field :student_id, :integer
    field :year, :string

    timestamps()
  end

  @doc false
  def changeset(student_comment, attrs) do
    student_comment
    |> cast(attrs, [:student_id, :semester_id, :class_id, :year, :comment1, :comment2, :comment3])
 
  end
end
