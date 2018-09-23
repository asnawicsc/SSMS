defmodule School.Repo.Migrations.AddInstitutionIdToSubject do
  use Ecto.Migration

  def change do
alter table("subject") do
      add(:institution_id, :integer)
    end
  end
end
