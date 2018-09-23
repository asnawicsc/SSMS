defmodule School.Repo.Migrations.AddInstitutionIdToStandardSubject do
  use Ecto.Migration

  def change do
alter table("standard_subject") do
      add(:institution_id, :integer)
    end
  end
end
