defmodule School.Repo.Migrations.AddNextClassToClass do
  use Ecto.Migration

  def change do
    alter table("classes") do
      add(:next_class, :string)
    end
  end
end
