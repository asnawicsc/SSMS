defmodule School.Repo.Migrations.CreateStudentCocurriculum do
  use Ecto.Migration

  def change do
    create table(:student_cocurriculum) do
      add :student_id, :integer
      add :cocurriculum_id, :integer
      add :standard_id, :integer
      add :grade, :string
      add :mark, :integer

      timestamps()
    end

  end
end
