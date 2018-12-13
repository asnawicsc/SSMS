defmodule School.Repo.Migrations.AddYear do
  use Ecto.Migration

  def change do
 alter table("history_exam") do
      add(:year, :integer)
    end
  end
end
