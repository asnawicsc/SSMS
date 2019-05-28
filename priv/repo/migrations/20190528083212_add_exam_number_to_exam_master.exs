defmodule School.Repo.Migrations.AddExamNumberToExamMaster do
  use Ecto.Migration

  def change do
    alter table("exam_master") do
      add(:exam_number, :integer)
    end
  end
end
