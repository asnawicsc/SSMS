defmodule School.Repo.Migrations.AddDescToEhomework do
  use Ecto.Migration

  def change do
    alter table("ehehomeworks") do
      add(:desc, :binary)
    end
  end
end
