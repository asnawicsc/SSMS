defmodule School.Repo.Migrations.CreateTeacherSchoolJob do
  use Ecto.Migration

  def change do
    create table(:teacher_school_job) do
      add :teacher_id, :integer
      add :school_job_id, :integer
      add :semester_id, :integer

      timestamps()
    end

  end
end
