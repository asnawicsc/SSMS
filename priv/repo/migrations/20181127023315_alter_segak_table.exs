defmodule School.Repo.Migrations.AlterSegakTable do
  use Ecto.Migration

  def change do
    alter table("segak") do
      remove(:student_id)
      remove(:semester_id)
      remove(:standard_id)
      remove(:class_id)
      remove(:mark)
      remove(:institution_id)
      add(:student_id, :integer)
      add(:semester_id, :integer)
      add(:standard_id, :integer)
      add(:class_id, :integer)
      add(:mark, :integer)
      add(:institution_id, :integer)
    end
  end
end
