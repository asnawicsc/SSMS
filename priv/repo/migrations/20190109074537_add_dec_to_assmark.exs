defmodule School.Repo.Migrations.AddDecToAssmark do
  use Ecto.Migration

  def change do
alter table("assessment_mark") do
  	 remove(:assessment_subject_level)
add(:assessment_subject_level, :integer)
add(:assessment_subject_level_desc, :string)
end
  end
end
