defmodule School.Repo.Migrations.AddCalId do
  use Ecto.Migration

  def change do
    alter table(:timetable) do
      add(:calender_id, :string)
      add(:teacher_id, :integer)
    end

    alter table(:period) do
      add(:recurring_frequency, :string)
      add(:recurring_until, :utc_datetime)
      add(:timetable_id, :integer)
      add(:start_datetime, :utc_datetime)
      add(:end_datetime, :utc_datetime)
    end
  end
end
