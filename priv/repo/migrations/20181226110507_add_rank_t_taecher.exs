defmodule School.Repo.Migrations.AddRankTTaecher do
  use Ecto.Migration

  def change do
 alter table("teacher") do
 

      add(:rank, :integer)
    end
  end
end
