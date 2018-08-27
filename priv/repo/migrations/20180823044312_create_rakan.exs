defmodule School.Repo.Migrations.CreateRakan do
  use Ecto.Migration

  def change do
    create table(:rakan) do
      add :prize, :string
      add :min, :integer
      add :max, :integer
      add :standard_id, :integer

      timestamps()
    end

  end
end
