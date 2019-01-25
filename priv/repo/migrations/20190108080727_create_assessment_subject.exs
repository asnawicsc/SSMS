defmodule School.Repo.Migrations.CreateAssessmentSubject do
  use Ecto.Migration

  def change do
    create table(:assessment_subject) do
      add :institution_id, :integer
      add :semester_id, :integer
      add :subject_id, :integer
      add :standard_id, :integer

      timestamps()
    end

  end
end
