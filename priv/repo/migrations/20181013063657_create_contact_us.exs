defmodule School.Repo.Migrations.CreateContactUs do
  use Ecto.Migration

  def change do
    create table(:contact_us) do
      add :name, :string
      add :email, :string
      add :message, :string

      timestamps()
    end

  end
end
