defmodule School.Repo.Migrations.CreateTeacherCoCurriculumJob do
  use Ecto.Migration

  def change do
    create table(:teacher_co_curriculum_job) do
      add :teacher_id, :integer
      add :co_curriculum_job_id, :integer
      add :semester_id, :integer

      timestamps()
    end

  end
end
