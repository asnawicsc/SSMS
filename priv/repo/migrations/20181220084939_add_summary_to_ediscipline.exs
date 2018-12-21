defmodule School.Repo.Migrations.AddSummaryToEdiscipline do
  use Ecto.Migration

  def change do
    alter table("edisciplines") do
      add(:summary, :binary)
    end
  end
end
