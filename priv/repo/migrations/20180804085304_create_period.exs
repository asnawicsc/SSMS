defmodule School.Repo.Migrations.CreatePeriod do
  use Ecto.Migration

  def change do
    create table(:period) do
      add :start_time, :time
      add :end_time, :time
      add :day, :string
      add :subject_id, :integer
      add :teacher_id, :integer

      timestamps()
    end

  end
end
