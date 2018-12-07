defmodule School.Repo.Migrations.AddEmailToParent do
  use Ecto.Migration

  def change do
    alter table("parent") do
      add(:email, :string)
    end
  end
end
