defmodule School.Repo.Migrations.AddstandardIdToJauhari do
  use Ecto.Migration

  def change do
   alter table("jauhari") do
      add(:standard_id, :integer)
    end
  end
end
