defmodule School.Repo.Migrations.AddEmailLoginToTeacher do
  use Ecto.Migration

  def change do
    alter table("teacher") do
      add(:email, :string)
    end
  end
end
