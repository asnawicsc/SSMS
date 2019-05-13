defmodule School.Repo.Migrations.AddInstitutionIdToCoco do
  use Ecto.Migration

  def change do
    alter table("subject") do
      add(:institution_id, :integer)
    end
  end
end
