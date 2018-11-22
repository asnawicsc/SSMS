defmodule School.Repo.Migrations.CreateExamGrade do
  use Ecto.Migration

  def change do
    create table(:exam_grade) do
      add :name, :string
      add :min, :integer
      add :max, :integer
      add :gpa, :decimal
      add :institution_id, :integer

      timestamps()
    end

  end
end
