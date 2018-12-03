defmodule School.Repo.Migrations.AddTeacherIdToAttendace do
  use Ecto.Migration

  def change do
    alter table("attendance") do
      add(:teacher_id, :string, default: "")
    end
  end
end
