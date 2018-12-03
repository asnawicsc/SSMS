defmodule School.Repo.Migrations.AddTeacherIdToAbsent do
  use Ecto.Migration

  def change do
    alter table("absent") do
      add(:teacher_id, :string)
    end
  end
end
