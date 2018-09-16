defmodule School.Repo.Migrations.AddInstitutionIdTohemJob do
  use Ecto.Migration

  def change do
alter table("teacher_hem_job") do
      add(:institution_id, :integer)
    end
  end
end
