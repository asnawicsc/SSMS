defmodule School.Repo.Migrations.CreateJauhari do
  use Ecto.Migration

  def change do
    create table(:jauhari) do
      add :prize, :string
      add :min, :integer
      add :max, :integer

      timestamps()
    end

  end
end
