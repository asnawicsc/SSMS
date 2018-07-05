defmodule School.Repo.Migrations.CreateAbsent do
  use Ecto.Migration

  def change do
    create table(:absent) do
      add :institution_id, :integer
      add :class_id, :integer
      add :student_id, :string
      add :semester_id, :integer
      add :reason, :string
      add :absent_date, :date

      timestamps()
    end

  end
end
