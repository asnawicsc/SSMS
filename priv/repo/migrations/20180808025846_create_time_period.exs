defmodule School.Repo.Migrations.CreateTimePeriod do
  use Ecto.Migration

  def change do
    create table(:time_period) do
      add :time_start, :time
      add :time_end, :time

      timestamps()
    end

  end
end
