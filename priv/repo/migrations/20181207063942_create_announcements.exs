defmodule School.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :message, :binary

      timestamps()
    end

  end
end
