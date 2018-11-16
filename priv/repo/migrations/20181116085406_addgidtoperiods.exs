defmodule School.Repo.Migrations.Addgidtoperiods do
  use Ecto.Migration

  def change do
    alter table(:period) do
      add(:google_event_id, :binary)
    end
  end
end
