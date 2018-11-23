defmodule School.Repo.Migrations.CreateBatches do
  use Ecto.Migration

  def change do
    create table(:batches) do
      add :upload_by, :integer
      add :result, :binary

      timestamps()
    end

  end
end
