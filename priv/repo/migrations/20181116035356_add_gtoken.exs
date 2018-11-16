defmodule School.Repo.Migrations.AddGtoken do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:g_token, :binary)
    end
  end
end
