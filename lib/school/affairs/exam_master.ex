defmodule School.Affairs.ExamMaster do
  use Ecto.Schema
  import Ecto.Changeset


  schema "exam_master" do
    field :level_id, :integer
    field :name, :string
    field :semester_id, :integer
    field :year, :string

    timestamps()
  end

  @doc false
  def changeset(exam_master, attrs) do
    exam_master
    |> cast(attrs, [:name, :semester_id, :level_id, :year])
    |> validate_required([:name, :semester_id, :level_id, :year])
  end
end
