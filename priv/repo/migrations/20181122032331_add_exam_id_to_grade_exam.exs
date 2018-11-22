defmodule School.Repo.Migrations.AddExamIdToGradeExam do
  use Ecto.Migration

  def change do
    alter table("exam_grade") do
      add(:exam_master_id, :integer)
    end
  end
end
