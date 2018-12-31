defmodule School.Repo.Migrations.CreateTeacherAttendance do
  use Ecto.Migration

  def change do
    create table(:teacher_attendance) do
      add :institution_id, :integer
      add :teacher_id, :integer
      add :semester_id, :integer
      add :time_id, :string
      add :time_out, :string

      timestamps()
    end

  end
end
