defmodule School.Repo.Migrations.AddInstitutionIdToLevel do
  use Ecto.Migration

  def change do
alter table("levels") do
      add(:institution_id, :integer)
    end
  end
end
