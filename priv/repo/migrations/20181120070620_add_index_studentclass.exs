defmodule School.Repo.Migrations.AddIndexStudentclass do
  use Ecto.Migration

  def change do
    create(
      unique_index(
        :student_classes,
        [:institute_id, :semester_id, :sudent_id],
        name: :index_all
      )
    )
  end
end
