defmodule School.Repo.Migrations.CreateTeacherPeriod do
  use Ecto.Migration

  def change do
    create table(:teacher_period) do
      add :class_id, :integer
      add :day, :string
      add :start_time, :time
      add :end_time, :time
      add :subject_id, :integer
      add :teacher_id, :integer

      timestamps()
    end

  end
end
