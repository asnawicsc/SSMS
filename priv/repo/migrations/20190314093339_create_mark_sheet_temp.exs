defmodule School.Repo.Migrations.CreateMarkSheetTemp do
  use Ecto.Migration

  def change do
    create table(:mark_sheet_temp) do
      add :institution_id, :integer
      add :stuid, :string
      add :name, :string
      add :cname, :string
      add :class, :string
      add :subject, :string
      add :description, :string
      add :cdesc, :string
      add :year, :string
      add :semester, :string
      add :s1m, :string
      add :s2m, :string
      add :s3m, :string
      add :s1g, :string
      add :s2g, :string
      add :s3g, :string

      timestamps()
    end

  end
end
