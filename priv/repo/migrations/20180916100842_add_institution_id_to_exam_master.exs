defmodule School.Repo.Migrations.AddInstitutionIdToExamMaster do
  use Ecto.Migration

  def change do
alter table("exam_master") do
      add(:institution_id, :integer)
    end
  end
end
