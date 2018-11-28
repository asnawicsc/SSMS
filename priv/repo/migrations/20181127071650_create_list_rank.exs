defmodule School.Repo.Migrations.CreateListRank do
  use Ecto.Migration

  def change do
    create table(:list_rank) do
      add :name, :string
      add :mark, :string
      add :integer, :string

      timestamps()
    end

  end
end
