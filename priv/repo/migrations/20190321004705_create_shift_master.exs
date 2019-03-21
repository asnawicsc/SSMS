defmodule School.Repo.Migrations.CreateShiftMaster do
  use Ecto.Migration

  def change do
    create table(:shift_master) do
      add :name, :string
      add :start_time, :time
      add :end_time, :time
      add :day, :string
      add :semester_id, :integer
      add :institution_id, :integer

      timestamps()
    end

  end
end
