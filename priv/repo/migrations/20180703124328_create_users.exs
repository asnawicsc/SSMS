defmodule School.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :password, :string
      add :crypted_password, :string
      add :institution_id, :integer
      add :role, :string

      timestamps()
    end

  end
end
