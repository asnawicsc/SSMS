defmodule School.Repo.Migrations.CreateGrade do
  use Ecto.Migration

  def change do
    create table(:grade) do
      add :name, :string
      add :max, :integer
      add :mix, :integer

      timestamps()
    end

  end
end
