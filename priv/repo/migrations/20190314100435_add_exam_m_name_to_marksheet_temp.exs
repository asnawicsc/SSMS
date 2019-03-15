defmodule School.Repo.Migrations.AddExamMNameToMarksheetTemp do
  use Ecto.Migration

  def change do
    alter table("mark_sheet_temp") do
      add(:exam_name, :string)
    end
  end
end
