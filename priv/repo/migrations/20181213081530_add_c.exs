defmodule School.Repo.Migrations.AddC do
  use Ecto.Migration

  def change do
 alter table("history_exam") do
      add(:chinese_name, :string)
    end
  end
end
