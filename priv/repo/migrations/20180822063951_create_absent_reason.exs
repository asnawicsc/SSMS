defmodule School.Repo.Migrations.CreateAbsentReason do
  use Ecto.Migration

  def change do
    create table(:absent_reason) do
      add :code, :string
      add :description, :string
      add :type, :string

      timestamps()
    end

  end
end
