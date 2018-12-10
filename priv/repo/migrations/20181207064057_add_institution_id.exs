defmodule School.Repo.Migrations.AddInstitutionId do
  use Ecto.Migration

  def change do
    alter table("announcements") do
      add(:institution_id, :integer)
    end
  end
end
