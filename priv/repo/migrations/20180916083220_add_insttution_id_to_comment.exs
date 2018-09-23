defmodule School.Repo.Migrations.AddInsttutionIdToComment do
  use Ecto.Migration

  def change do
alter table("comment") do
      add(:institution_id, :integer)
    end
  end
end
