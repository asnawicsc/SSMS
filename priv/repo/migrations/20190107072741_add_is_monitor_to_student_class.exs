defmodule School.Repo.Migrations.AddIsMonitorToStudentClass do
  use Ecto.Migration

  def change do
alter table("student_classes") do
      add(:is_monitor, :integer)
    end
  end
end
