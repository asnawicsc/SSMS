defmodule School.Repo.Migrations.AddLogoBin do
  use Ecto.Migration

  def change do
    alter table("institutions") do
      add(:maintained_by, :string)
    end
  end
end
