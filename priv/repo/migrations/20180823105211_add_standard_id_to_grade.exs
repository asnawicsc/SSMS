defmodule School.Repo.Migrations.AddStandardIdToGrade do
  use Ecto.Migration

  def change do
  alter table("grade") do
      add(:standard_id, :integer)
    end
  end
end
