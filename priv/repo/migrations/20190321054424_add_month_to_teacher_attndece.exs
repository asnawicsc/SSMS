defmodule School.Repo.Migrations.AddMonthToTeacherAttndece do
  use Ecto.Migration

  def change do
 alter table("teacher_attendance") do
      add(:month, :string)
     
    end
  end
end
