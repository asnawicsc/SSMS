defmodule School.Repo.Migrations.AddInstitutionIdToAbsentReason do
  use Ecto.Migration

  def change do
alter table("absent_reason") do
      add(:institution_id, :integer)
    end
  end
end
