defmodule School.Repo.Migrations.CreateTimetable do
  use Ecto.Migration

  def change do
    create table(:timetable) do
      add :class_id, :integer
      add :institution_id, :integer
      add :level_id, :integer
      add :period_id, :integer
      add :semester_id, :integer

      timestamps()
    end

  end
end
