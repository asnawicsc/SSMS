defmodule School.Repo.Migrations.AddInstIdToAbsentHist do
  use Ecto.Migration

  def change do
    alter table("absent_history") do
      add(:institution_id, :integer)
    end
  end
end
