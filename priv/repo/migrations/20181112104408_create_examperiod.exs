defmodule School.Repo.Migrations.CreateExamperiod do
  use Ecto.Migration

  def change do
    create table(:examperiod) do
      add :start_date, :naive_datetime
      add :end_date, :naive_datetime
      add :exam_id, :integer

      timestamps()
    end

  end
end
