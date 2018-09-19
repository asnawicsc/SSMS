defmodule School.Repo.Migrations.AddInstitutionIdToJauhari do
  use Ecto.Migration

  def change do
alter table("jauhari") do
      add(:institution_id, :integer)
  end
  end
end
