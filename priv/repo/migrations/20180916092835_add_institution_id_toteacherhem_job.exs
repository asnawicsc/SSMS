defmodule School.Repo.Migrations.AddInstitutionIdToteacherhemJob do
  use Ecto.Migration

  def change do
alter table("hem_job") do
      add(:institution_id, :integer)
    end
  end
end
