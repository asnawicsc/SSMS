defmodule School.Repo.Migrations.CreateUserAccess do
  use Ecto.Migration

  def change do
    create table(:user_access) do
      add :user_id, :integer
      add :institution_id, :integer

      timestamps()
    end

  end
end
