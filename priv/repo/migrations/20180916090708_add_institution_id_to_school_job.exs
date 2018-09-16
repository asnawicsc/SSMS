defmodule School.Repo.Migrations.AddInstitutionIdToSchoolJob do
  use Ecto.Migration

  def change do
	alter table("teacher_school_job") do
      add(:institution_id, :integer)
    end
  end
end
