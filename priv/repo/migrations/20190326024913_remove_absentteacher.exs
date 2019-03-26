defmodule School.Repo.Migrations.RemoveAbsentteacher do
  use Ecto.Migration

  def change do
alter table("teacher_absent_reason") do
  	 remove(:absent_reason_id)
	remove(:semester_id)
	remove(:teacher_id)
	 add(:absent_reason, :string)
	  add(:institution_id, :integer)
end
  end
end
