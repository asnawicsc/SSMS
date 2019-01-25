defmodule School.Repo.Migrations.CreateRulesBreak do
  use Ecto.Migration

  def change do
    create table(:rules_break) do
      add :institution_id, :integer
      add :level, :integer
      add :remark, :string

      timestamps()
    end

  end
end
