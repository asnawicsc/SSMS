defmodule School.Repo.Migrations.AddBcertToStudents do
  use Ecto.Migration

  def change do
    alter table("students") do
      add(:b_cert, :string)
      add(:achievements, :binary)
      add(:remarks, :binary)
    end
  end
end
