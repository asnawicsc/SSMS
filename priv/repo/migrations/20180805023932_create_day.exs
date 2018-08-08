defmodule School.Repo.Migrations.CreateDay do
  use Ecto.Migration

  def change do
    create table(:day) do
      add :name, :string

      timestamps()
    end

  end
end
