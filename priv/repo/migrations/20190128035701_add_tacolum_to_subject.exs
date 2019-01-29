defmodule School.Repo.Migrations.AddTacolumToSubject do
  use Ecto.Migration

  def change do
    alter table("subject") do
      add(:timetable_description, :string)
      add(:timetable_code, :string)
    end
  end
end
