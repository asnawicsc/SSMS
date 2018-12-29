defmodule School.Repo.Migrations.AddIsAccessToUserAccess do
  use Ecto.Migration

  def change do
 alter table("user_access") do
 

      add(:is_access, :integer)
    end
  end
end
