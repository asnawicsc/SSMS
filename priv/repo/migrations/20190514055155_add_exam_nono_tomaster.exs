defmodule School.Repo.Migrations.AddExamNonoTomaster do
  use Ecto.Migration

  def change do
alter table("exam_master") do
   
      add(:exam_no, :integer)
      
end
  end
end
