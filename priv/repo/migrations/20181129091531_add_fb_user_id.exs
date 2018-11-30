defmodule School.Repo.Migrations.AddFbUserId do
  use Ecto.Migration

  def change do
    alter table(:parent) do
      add(:fb_user_id, :string)
      add(:role, :string, default: "Parent")
    end
  end
end
