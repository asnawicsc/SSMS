defmodule School.Repo.Migrations.CreateStudentClasses do
  use Ecto.Migration

  def change do
    create table(:student_classes) do
      add :institute_id, :integer
      add :level_id, :integer
      add :semester_id, :integer
      add :class_id, :integer
      add :sudent_id, :integer

      timestamps()
    end

  end
end
