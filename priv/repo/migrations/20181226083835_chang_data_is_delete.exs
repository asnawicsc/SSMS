defmodule School.Repo.Migrations.ChangDataIsDelete do
  use Ecto.Migration

  def change do
    alter table("teacher") do
      remove(:is_delete)

      add(:is_delete, :integer)
    end
  end
end
