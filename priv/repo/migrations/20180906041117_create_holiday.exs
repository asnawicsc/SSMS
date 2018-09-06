defmodule School.Repo.Migrations.CreateHoliday do
  use Ecto.Migration

  def change do
    create table(:holiday) do
      add :date, :date
      add :description, :string
      add :semester_id, :integer
      add :institution_id, :integer

      timestamps()
    end

  end
end
