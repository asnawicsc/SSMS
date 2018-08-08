defmodule School.Repo.Migrations.CreateExamMaster do
  use Ecto.Migration

  def change do
    create table(:exam_master) do
      add :name, :string
      add :semester_id, :integer
      add :level_id, :integer
      add :year, :string

      timestamps()
    end

  end
end
