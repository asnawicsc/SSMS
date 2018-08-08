defmodule School.Repo.Migrations.CreateExamMark do
  use Ecto.Migration

  def change do
    create table(:exam_mark) do
      add :class_id, :integer
      add :exam_id, :integer
      add :mark, :integer
      add :subject_id, :integer
      add :student_id, :integer

      timestamps()
    end

  end
end
