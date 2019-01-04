defmodule School.Repo.Migrations.AddBlobToStudent do
  use Ecto.Migration

  def change do
alter table("students") do
      add(:image, :binary)
    end
  end
end
