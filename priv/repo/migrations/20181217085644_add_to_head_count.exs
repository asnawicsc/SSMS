defmodule School.Repo.Migrations.AddToHeadCount do
  use Ecto.Migration

  def change do
    alter table("head_counts") do
      add(:institution_id, :integer)
      add(:semester_id, :integer)
    end
  end
end
