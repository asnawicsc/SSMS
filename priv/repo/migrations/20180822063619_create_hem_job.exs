defmodule School.Repo.Migrations.CreateHemJob do
  use Ecto.Migration

  def change do
    create table(:hem_job) do
      add :code, :string
      add :description, :string
      add :cdesc, :string

      timestamps()
    end

  end
end
