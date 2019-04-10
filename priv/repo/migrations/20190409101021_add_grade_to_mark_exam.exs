defmodule School.Repo.Migrations.AddGradeToMarkExam do
  use Ecto.Migration

  def change do
alter table("exam_mark") do
      add(:grade, :string)
     
    end
  end
end
