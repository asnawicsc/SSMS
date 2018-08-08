defmodule School.Repo.Migrations.AddGpaTToGrade do
  use Ecto.Migration

  def change do
 		alter table(:grade) do
      add :gpa, :decimal
  end
  end
end
