defmodule School.Repo.Migrations.CreateSubject do
  use Ecto.Migration

  def change do
    create table(:subject) do
      add :code, :string
      add :description, :string
      add :cdesc, :string
      add :sysdef, :integer

      timestamps()
    end

  end
end
