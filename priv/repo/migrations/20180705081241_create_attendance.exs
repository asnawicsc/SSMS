defmodule School.Repo.Migrations.CreateAttendance do
  use Ecto.Migration

  def change do
    create table(:attendance) do
      add :institution_id, :integer
      add :class_id, :integer
      add :student_id, :string
      add :semester_id, :integer
      add :attendance_date, :date
      add :mark_by, :string

      timestamps()
    end

  end
end
