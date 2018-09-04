defmodule School.Affairs.StudentCocurriculum do
  use Ecto.Schema
  import Ecto.Changeset


  schema "student_cocurriculum" do
    field :cocurriculum_id, :integer
    field :grade, :string
    field :mark, :integer
    field :standard_id, :integer
    field :student_id, :integer
     field :year, :string
          field :semester_id, :integer


    timestamps()
  end

  @doc false
  def changeset(student_cocurriculum, attrs) do
    student_cocurriculum
    |> cast(attrs, [:student_id, :cocurriculum_id, :standard_id, :grade, :mark,:year,:semester_id])
  end
end