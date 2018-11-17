defmodule School.Repo.Migrations.AddIsLibrarianToUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:is_librarian, :boolean)
    end
  end
end
