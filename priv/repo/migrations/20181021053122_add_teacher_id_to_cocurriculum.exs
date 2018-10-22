defmodule School.Repo.Migrations.AddTeacherIdToCocurriculum do
  use Ecto.Migration

  def change do
    alter table("cocurriculum") do
      add(:teacher_id, :integer)
    end
  end
end
