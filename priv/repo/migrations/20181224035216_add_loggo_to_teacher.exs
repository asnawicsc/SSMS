defmodule School.Repo.Migrations.AddLoggoToTeacher do
  use Ecto.Migration

  def change do
    alter table("teacher") do
      add(:image_bin, :binary)
      add(:image_filename, :string)
    end
  end
end
