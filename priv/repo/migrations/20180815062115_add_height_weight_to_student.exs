defmodule School.Repo.Migrations.AddHeightWeightToStudent do
  use Ecto.Migration

  def change do
    alter table("students") do
      add(:height, :string)
      add(:weight, :string)
    end
  end
end
