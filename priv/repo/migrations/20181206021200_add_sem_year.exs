defmodule School.Repo.Migrations.AddSemYear do
  use Ecto.Migration

  def change do
    alter table("semesters") do
      add(:sem, :integer)
      add(:year, :integer)
    end
  end
end
