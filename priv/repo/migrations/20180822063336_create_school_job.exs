defmodule School.Repo.Migrations.CreateSchoolJob do
  use Ecto.Migration

  def change do
    create table(:school_job) do
      add :code, :string
      add :description, :string
      add :cdesc, :string

      timestamps()
    end

  end
end
