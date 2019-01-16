defmodule School.Repo.Migrations.CreateMarkSheetHistorys do
  use Ecto.Migration

  def change do
    create table(:mark_sheet_historys) do
      add :institution_id, :integer
      add :stuid, :string
      add :name, :string
      add :cname, :string
      add :class, :string
      add :subject, :string
      add :description, :string
      add :cdesc, :string
      add :year, :string
      add :t1m, :string
      add :t2m, :string
      add :t3m, :string
      add :t4m, :string
      add :t5m, :string
      add :t6m, :string
      add :s1m, :string
      add :s2m, :string
      add :t1g, :string
      add :t2g, :string
      add :t3g, :string
      add :t4g, :string
      add :t5g, :string
      add :t6g, :string
      add :s1g, :string
      add :s2g, :string
      add :s3g, :string

      timestamps()
    end

  end
end
