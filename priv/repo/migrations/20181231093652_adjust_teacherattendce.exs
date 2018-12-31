defmodule School.Repo.Migrations.AdjustTeacherattendce do
  use Ecto.Migration

  def change do
 alter table("teacher_attendance") do
      remove(:time_id)

      add(:time_in, :string)
       add(:date, :string)
    end
  end
end
