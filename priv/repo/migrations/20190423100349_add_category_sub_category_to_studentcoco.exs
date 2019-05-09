defmodule School.Repo.Migrations.AddCategorySubCategoryToStudentcoco do
  use Ecto.Migration

  def change do
    alter table("student_cocurriculum") do
      add(:category, :string)
      add(:sub_category, :string)
    end
  end
end
