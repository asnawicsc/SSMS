defmodule School.Repo.Migrations.AddLevelTosubjectStandard do
  use Ecto.Migration

  def change do
alter table("assessment_subject") do
      add(:level1, :string)
      add(:level2, :string)
      add(:level3, :string)
      add(:level4, :string)
      add(:level5, :string)
      add(:level6, :string)
  end
end
end
