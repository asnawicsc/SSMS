defmodule School.Repo.Migrations.AddClassIdToPeriod do
  use Ecto.Migration

    def change do
    alter table(:period) do
    
      add :class_id, :integer

    end

  end
end
