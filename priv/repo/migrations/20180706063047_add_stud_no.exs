defmodule School.Repo.Migrations.AddStudNo do
  use Ecto.Migration

  def change do
    alter table("students") do
      add(:student_no, :string)
    end
  end
end
