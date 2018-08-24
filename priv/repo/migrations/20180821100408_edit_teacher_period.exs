defmodule School.Repo.Migrations.EditTeacherPeriod do
  use Ecto.Migration

  def change do
  		alter table("teacher_period") do
      remove(:class_id)
      remove(:subject_id)
      add(:activity, :string)
      add(:place, :string)
  end

  end
end
