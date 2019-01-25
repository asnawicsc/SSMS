defmodule School.Repo.Migrations.AddRegQdateToStudent do
  use Ecto.Migration

  def change do
alter table("students") do

      add(:register_date, :string)
       add(:quit_date, :string)
    end
  end
end
