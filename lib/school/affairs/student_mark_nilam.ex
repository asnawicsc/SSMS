defmodule School.Affairs.StudentMarkNilam do
  use Ecto.Schema
  import Ecto.Changeset


  schema "student_mark_nilam" do
    field :institution_id, :integer
    field :student_id, :integer
    field :total_book, :integer
    field :year, :integer

    timestamps()
  end

  @doc false
  def changeset(student_mark_nilam, attrs) do
    student_mark_nilam
    |> cast(attrs, [:student_id, :institution_id, :total_book, :year])
    |> validate_required([:student_id, :institution_id, :total_book, :year])
  end
end
