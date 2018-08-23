defmodule School.Repo.Migrations.CreateTeacherHemJob do
  use Ecto.Migration

  def change do
    create table(:teacher_hem_job) do
      add :teacher_id, :integer
      add :hem_job_id, :integer
      add :semester_id, :integer

      timestamps()
    end

  end
end
