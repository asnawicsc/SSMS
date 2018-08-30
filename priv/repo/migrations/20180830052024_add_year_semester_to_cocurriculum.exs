defmodule School.Repo.Migrations.AddYearSemesterToCocurriculum do
  use Ecto.Migration

  def change do
   alter table("student_cocurriculum") do
      add(:year, :string)
      add(:semester_id, :integer)

    end
  end
end
