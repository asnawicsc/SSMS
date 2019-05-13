defmodule School.Repo.Migrations.CreateStudentCocoAchievements do
  use Ecto.Migration

  def change do
    create table(:student_coco_achievements) do
      add :student_id, :integer
      add :date, :date
      add :category, :string
      add :participant_type, :string
      add :peringkat, :string
      add :sub_category, :string
      add :competition_name, :string
      add :rank, :string

      timestamps()
    end

  end
end
