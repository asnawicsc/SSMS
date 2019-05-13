defmodule School.Repo.Migrations.CreateCocoRanks do
  use Ecto.Migration

  def change do
    create table(:coco_ranks) do
      add :sub_category, :string
      add :rank, :string

      timestamps()
    end

  end
end
