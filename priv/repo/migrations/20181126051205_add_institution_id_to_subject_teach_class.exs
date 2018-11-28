defmodule School.Repo.Migrations.AddInstitutionIdToSubjectTeachClass do
  use Ecto.Migration

  def change do
    alter table("subject_teach_class") do
      add(:institution_id, :integer)
    end
  end
end
