defmodule School.Repo.Migrations.CreateHeadCounts do
  use Ecto.Migration

  def change do
    create table(:head_counts) do
      add :class_id, :integer
      add :subject_id, :integer
      add :student_id, :integer
      add :targer_mark, :integer

      timestamps()
    end

  end
end
