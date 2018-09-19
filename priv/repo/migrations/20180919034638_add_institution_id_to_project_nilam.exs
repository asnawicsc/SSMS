defmodule School.Repo.Migrations.AddInstitutionIdToProjectNilam do
  use Ecto.Migration

  def change do
alter table("project_nilam") do
      add(:institution_id, :integer)
    end
  end
end
