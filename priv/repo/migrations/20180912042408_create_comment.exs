defmodule School.Repo.Migrations.CreateComment do
  use Ecto.Migration

  def change do
    create table(:comment) do
      add :code, :string
      add :c_chinese, :string
      add :c_malay, :string

      timestamps()
    end

  end
end
