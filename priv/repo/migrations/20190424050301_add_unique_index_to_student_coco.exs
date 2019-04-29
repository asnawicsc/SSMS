defmodule School.Repo.Migrations.AddUniqueIndexToStudentCoco do
  use Ecto.Migration

  def change do
    create(
      unique_index(:student_cocurriculum, [:student_id, :semester_id, :category],
        name: :student_semester_index
      )
    )
  end
end
