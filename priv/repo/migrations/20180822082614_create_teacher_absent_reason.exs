defmodule School.Repo.Migrations.CreateTeacherAbsentReason do
  use Ecto.Migration

  def change do
    create table(:teacher_absent_reason) do
      add :teacher_id, :integer
      add :absent_reason_id, :integer
      add :semester_id, :integer

      timestamps()
    end

  end
end
