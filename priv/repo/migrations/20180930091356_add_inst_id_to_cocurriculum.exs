defmodule School.Repo.Migrations.AddInstIdToCocurriculum do
  use Ecto.Migration

  def change do
alter table("cocurriculum") do
      add(:institution_id, :integer)
  end
  end
end