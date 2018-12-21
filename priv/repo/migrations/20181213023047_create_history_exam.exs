defmodule School.Repo.Migrations.CreateHistoryExam do
  use Ecto.Migration

  def change do
    create table(:history_exam) do
      add :student_no, :integer
      add :student_name, :string
      add :subject_name, :string
      add :subject_code, :string
      add :subject_mark, :decimal
      add :exam_class_rank, :integer
      add :exam_standard_rank, :integer
      add :exam_name, :string
      add :class_name, :string
      add :semester_id, :integer
      add :institution_id, :integer
      add :exam_grade, :string

      timestamps()
    end

  end
end
