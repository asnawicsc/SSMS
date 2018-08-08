defmodule School.Repo.Migrations.AddLibraryOrganizationId do
  use Ecto.Migration

  def change do
    alter table("institutions") do
      add(:library_organization_id, :integer)
    end
  end
end
