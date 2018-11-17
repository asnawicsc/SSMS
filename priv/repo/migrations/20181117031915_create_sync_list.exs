defmodule School.Repo.Migrations.CreateSyncList do
  use Ecto.Migration

  def change do
    create table(:sync_list) do
      add :period_id, :integer
      add :status, :string
      add :executed_time, :utc_datetime

      timestamps()
    end

  end
end
