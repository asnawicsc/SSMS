defmodule School.Repo.Migrations.AddInstitutionIdToCocuriulumJob do
  use Ecto.Migration

  def change do
alter table("teacher_co_curriculum_job") do
      add(:institution_id, :integer)
    end
  end
end
