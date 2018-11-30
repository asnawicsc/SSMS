defmodule School.Repo.Migrations.AddUniqueStudentNo do
  use Ecto.Migration

  def change do
    create(unique_index(:students, [:student_no]))
  end
end
