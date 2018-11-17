defmodule School.Repo.Migrations.AddStyleUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:styles, :binary, default: "/css/theme-a.css")
    end
  end
end
