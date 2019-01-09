defmodule School.Repo.Migrations.AddLevelToAssesmentMark do
  use Ecto.Migration

  def change do
alter table("assessment_mark") do
      add(:assessment_subject_id, :integer)
      add(:assessment_subject_level, :string)

       remove(:rules_break_id)
  end
  end
end
