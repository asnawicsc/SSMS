defmodule School.Repo.Migrations.CreateSegak do
  use Ecto.Migration

  def change do
    create table(:segak) do
      add(:student_id, :string)
      add(:semester_id, :string)
      add(:standard_id, :string)
      add(:class_id, :string)
      add(:mark, :string)
      add(:institution_id, :string)

      timestamps()
    end
  end
end
