defmodule School.Repo.Migrations.AddInstitutionIdToExamperiod do
  use Ecto.Migration

  def change do
    alter table("examperiod") do
      add(:institution_id, :integer)
    end
  end
end
