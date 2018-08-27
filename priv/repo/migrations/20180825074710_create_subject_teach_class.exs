defmodule School.Repo.Migrations.CreateSubjectTeachClass do
  use Ecto.Migration

  def change do
    create table(:subject_teach_class) do
      add :standard_id, :integer
      add :subject_id, :integer
      add :teacher_id, :integer
      add :class_id, :integer

      timestamps()
    end

  end
end
