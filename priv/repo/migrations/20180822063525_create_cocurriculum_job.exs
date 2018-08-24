defmodule School.Repo.Migrations.CreateCocurriculumJob do
  use Ecto.Migration

  def change do
    create table(:cocurriculum_job) do
      add :code, :string
      add :description, :string
      add :cdesc, :string

      timestamps()
    end

  end
end
