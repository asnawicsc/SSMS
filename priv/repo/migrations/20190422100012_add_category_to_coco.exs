defmodule School.Repo.Migrations.AddCategoryToCoco do
  use Ecto.Migration

  def change do
    alter table("cocurriculum") do
      add(:category, :string)
      add(:sub_category, :string)
      add(:student_id, :integer)
      add(:class_id, :integer)
    end
  end
end
