defmodule School.Repo.Migrations.CreateExam do
  use Ecto.Migration

  def change do
    create table(:exam) do
      add :subject_id, :integer
      add :exam_master_id, :integer

      timestamps()
    end

  end
end
