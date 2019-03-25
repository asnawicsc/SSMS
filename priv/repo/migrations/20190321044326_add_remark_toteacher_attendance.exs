defmodule School.Repo.Migrations.AddRemarkToteacherAttendance do
  use Ecto.Migration

  def change do
 alter table("teacher_attendance") do
      add(:remark, :string)
     
    end
  end
end
