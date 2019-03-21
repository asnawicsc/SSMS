defmodule School.Repo.Migrations.CreateShift do
  use Ecto.Migration

  def change do
    create table(:shift) do
      add :teacher_id, :integer
      add :shift_master_id, :integer

      timestamps()
    end

  end
end
