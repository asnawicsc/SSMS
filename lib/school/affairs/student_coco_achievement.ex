defmodule School.Affairs.Student_coco_achievement do
  use Ecto.Schema
  import Ecto.Changeset


  schema "student_coco_achievements" do
    field :category, :string
    field :competition_name, :string
    field :date, :date
    field :participant_type, :string
    field :peringkat, :string
    field :rank, :string
    field :student_id, :integer
    field :sub_category, :string

    timestamps()
  end

  @doc false
  def changeset(student_coco_achievement, attrs) do
    student_coco_achievement
    |> cast(attrs, [:student_id, :date, :category, :participant_type, :peringkat, :sub_category, :competition_name, :rank])
    |> validate_required([:student_id, :date, :category, :participant_type, :peringkat, :sub_category, :competition_name, :rank])
  end
end
