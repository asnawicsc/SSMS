defmodule School.Repo.Migrations.CreateExamAttendance do
  use Ecto.Migration

  def change do
    create table(:exam_attendance) do
      add :student_id, :integer
      add :class_id, :integer
      add :exam_id, :integer
      add :exam_master_id, :integer
      add :subject_id, :integer
      add :semester_id, :integer
      add :institution_id, :integer

      timestamps()
    end

  end
end
