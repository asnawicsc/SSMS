defmodule School.Repo.Migrations.AddTeacherClassToClass do
  use Ecto.Migration

  def change do
   alter table("classes") do
      add(:teacher_id, :integer)

    end
   end
end
