defmodule School.Repo.Migrations.ChangeTypeGrade do
  use Ecto.Migration

  def change do
  	alter table("exam_grade") do
     remove(:max)
     remove(:min)
      add(:max, :decimal)
       add(:min, :decimal)
end
  end
end
