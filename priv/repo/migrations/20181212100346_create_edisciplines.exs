defmodule School.Repo.Migrations.CreateEdisciplines do
  use Ecto.Migration

  def change do
    create table(:edisciplines) do
      add :title, :string
      add :message, :binary
      add :psid, :string
      add :teacher_id, :integer

      timestamps()
    end

  end
end
