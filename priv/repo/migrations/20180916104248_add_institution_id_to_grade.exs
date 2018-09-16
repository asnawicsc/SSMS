defmodule School.Repo.Migrations.AddInstitutionIdToGrade do
  use Ecto.Migration

  def change do
alter table("grade") do
      add(:institution_id, :integer)
    end
  end
end
