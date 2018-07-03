defmodule School.Repo.Migrations.CreateInstitutions do
  use Ecto.Migration

  def change do
    create table(:institutions) do
      add :name, :string
      add :line1, :string
      add :line2, :string
      add :town, :string
      add :postcode, :string
      add :state, :string
      add :country, :string
      add :phone, :string
      add :phone2, :string
      add :email, :string
      add :email2, :string
      add :fax, :string
      add :logo_bin, :binary
      add :logo_filename, :string

      timestamps()
    end

  end
end
