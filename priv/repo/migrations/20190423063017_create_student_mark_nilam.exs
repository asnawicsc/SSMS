defmodule School.Repo.Migrations.CreateStudentMarkNilam do
  use Ecto.Migration

  def change do
    create table(:student_mark_nilam) do
      add :student_id, :integer
      add :institution_id, :integer
      add :total_book_integer, :string
      add :year, :integer

      timestamps()
    end

  end
end
