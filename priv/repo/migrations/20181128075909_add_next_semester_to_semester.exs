defmodule School.Repo.Migrations.AddNextSemesterToSemester do
  use Ecto.Migration

  def change do
    alter table("semesters") do
      add(:next_semester_id, :integer)
    end
  end
end
