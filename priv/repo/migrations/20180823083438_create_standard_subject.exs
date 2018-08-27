defmodule School.Repo.Migrations.CreateStandardSubject do
  use Ecto.Migration

  def change do
    create table(:standard_subject) do
      add :year, :string
      add :semester_id, :integer
      add :standard_id, :integer
      add :subject_id, :integer

      timestamps()
    end

  end
end
