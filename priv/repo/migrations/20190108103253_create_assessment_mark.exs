defmodule School.Repo.Migrations.CreateAssessmentMark do
  use Ecto.Migration

  def change do
    create table(:assessment_mark) do
      add :institution_id, :integer
      add :semester_id, :integer
      add :subject_id, :integer
      add :standard_id, :integer
      add :class_id, :integer
      add :student_id, :integer
      add :rules_break_id, :integer

      timestamps()
    end

  end
end
