defmodule School.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters) do
      add :start_date, :date
      add :end_date, :date
      add :holiday_start, :date
      add :holiday_end, :date
      add :school_days, :integer

      timestamps()
    end

  end
end
