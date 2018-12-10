defmodule School.Repo.Migrations.AddPsidToParent do
  use Ecto.Migration

  def change do
    alter table(:parent) do
      add(:psid, :string)
    end
  end
end
