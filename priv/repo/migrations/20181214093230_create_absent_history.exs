defmodule School.Repo.Migrations.CreateAbsentHistory do
  use Ecto.Migration

  def change do
    create table(:absent_history) do
      add :student_no, :integer
      add :student_name, :string
      add :chinese_name, :string
      add :student_class, :string
      add :absent_date, :string
      add :absent_type, :string
      add :year, :integer

      timestamps()
    end

  end
end
