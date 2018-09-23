defmodule School.Repo.Migrations.AddInstitutionIdToParent do
  use Ecto.Migration

  def change do
alter table("parent") do
      add(:institution_id, :integer)
    end
  end
end
