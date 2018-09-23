defmodule School.Repo.Migrations.AddInstitutionIdToSemester do
  use Ecto.Migration

  def change do
alter table("semesters") do
      add(:institution_id, :integer)
    end
  end
end
