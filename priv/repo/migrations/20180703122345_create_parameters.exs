defmodule School.Repo.Migrations.CreateParameters do
  use Ecto.Migration

  def change do
    create table(:parameters) do
      add :nationality, :binary
      add :race, :binary
      add :religion, :binary
      add :blood_type, :binary
      add :transport, :binary
      add :sickness, :binary
      add :career, :binary
      add :oku, :binary
      add :institution_id, :integer

      timestamps()
    end

  end
end
