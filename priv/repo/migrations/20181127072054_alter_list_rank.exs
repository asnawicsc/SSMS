defmodule School.Repo.Migrations.AlterListRank do
  use Ecto.Migration

  def change do
    alter table("list_rank") do
      remove(:integer)
      remove(:mark)

      add(:mark, :integer)
      add(:institution_id, :integer)
    end
  end
end
