defmodule School.Repo.Migrations.AddInstitutionIdToTeacher do
  use Ecto.Migration

  def change do
  	alter table("teacher") do
      add(:institution_id, :integer)
    end

  end
end
