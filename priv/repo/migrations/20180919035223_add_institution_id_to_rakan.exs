defmodule School.Repo.Migrations.AddInstitutionIdToRakan do
  use Ecto.Migration

  def change do
alter table("rakan") do
      add(:institution_id, :integer)
  end
  end
end
