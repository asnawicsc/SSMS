defmodule School.Repo.Migrations.AddLoggoToStudent do
  use Ecto.Migration

  def change do
    alter table("students") do
      add(:image_bin, :binary)
      add(:image_filename, :string)
    end
  end
end
