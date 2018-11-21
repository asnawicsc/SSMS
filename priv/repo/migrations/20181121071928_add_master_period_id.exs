defmodule School.Repo.Migrations.AddMasterPeriodId do
  use Ecto.Migration

  def change do
    alter table(:period) do
      add(:master_period_id, :integer)
    end
  end
end
