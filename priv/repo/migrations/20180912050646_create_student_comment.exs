defmodule School.Repo.Migrations.CreateStudentComment do
  use Ecto.Migration

  def change do
    create table(:student_comment) do
      add :student_id, :integer
      add :semester_id, :integer
      add :class_id, :integer
      add :year, :string
      add :comment1, :string
      add :comment2, :string
      add :comment3, :string

      timestamps()
    end

  end
end
