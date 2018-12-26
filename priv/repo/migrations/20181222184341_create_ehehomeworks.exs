defmodule School.Repo.Migrations.CreateEhehomeworks do
  use Ecto.Migration

  def change do
    create table(:ehehomeworks) do
      add :subject_id, :integer
      add :start_date, :date
      add :end_date, :date
      add :semester_id, :integer
      add :class_id, :integer

      timestamps()
    end

  end
end
