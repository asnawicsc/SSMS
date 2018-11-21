defmodule School.Repo.Migrations.AddCocoIndex do
  use Ecto.Migration

  def change do
    create(
      unique_index(
        :student_cocurriculum,
        [:student_id, :semester_id, :cocurriculum_id],
        name: :index_all_coco
      )
    )
  end
end
