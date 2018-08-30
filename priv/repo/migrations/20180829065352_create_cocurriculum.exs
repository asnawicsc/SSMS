defmodule School.Repo.Migrations.CreateCocurriculum do
  use Ecto.Migration

  def change do
    create table(:cocurriculum) do
      add :code, :string
      add :description, :string

      timestamps()
    end

  end
end
