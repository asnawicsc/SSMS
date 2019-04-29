defmodule School.Repo.Migrations.AddTimetableCode do
  use Ecto.Migration

  def change do
    alter table("subject") do
      add(:timetable_code, :string)
    end
  end
end
