defmodule School.Repo.Migrations.CreateLabels do
  use Ecto.Migration

  def change do
    create table(:labels) do
      add :name, :string
      add :en, :string
      add :cn, :string
      add :bm, :string

      timestamps()
    end

  end
end
