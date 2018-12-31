defmodule School.Repo.Migrations.AddIsDeleteToClass do
  use Ecto.Migration

  def change do
    alter table("classes") do
      add(:is_delete, :integer)
    end
  end
end
