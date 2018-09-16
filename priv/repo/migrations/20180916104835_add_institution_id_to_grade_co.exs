defmodule School.Repo.Migrations.AddInstitutionIdToGradeCo do
  use Ecto.Migration

  def change do
alter table("co_grade") do
      add(:institution_id, :integer)
    end
  end
end
