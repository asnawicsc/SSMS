defmodule School.Repo.Migrations.AddRankTostudentCo do
  use Ecto.Migration

  def change do
    alter table("student_cocurriculum") do
      add(:rank, :string)
    end
  end
end
