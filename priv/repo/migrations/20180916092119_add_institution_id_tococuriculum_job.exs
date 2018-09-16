defmodule School.Repo.Migrations.AddInstitutionIdTococuriculumJob do
  use Ecto.Migration

  def change do
	alter table("cocurriculum_job") do
      add(:institution_id, :integer)
    end
  end
end
