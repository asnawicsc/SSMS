defmodule School.Repo.Migrations.CreateCoGrade do
  use Ecto.Migration

  def change do
    create table(:co_grade) do
      add :name, :string
      add :max, :integer
      add :min, :integer
      add :gpa, :decimal

      timestamps()
    end

  end
end
