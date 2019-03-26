defmodule School.Repo.Migrations.CreateTeacherAbsent do
  use Ecto.Migration

  def change do
    create table(:teacher_absent) do
      add :institution_id, :integer
      add :semester_id, :integer
      add :teacher_id, :integer
      add :date, :date
      add :remark, :string
      add :month, :string
      add :alasan, :string

      timestamps()
    end

  end
end
