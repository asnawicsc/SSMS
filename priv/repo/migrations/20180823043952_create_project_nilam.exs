defmodule School.Repo.Migrations.CreateProjectNilam do
  use Ecto.Migration

  def change do
    create table(:project_nilam) do
      add :below_satisfy, :integer
      add :member_reading_quantity, :integer
      add :page, :integer
      add :import_from_library, :integer
      add :count_page, :integer
      add :standard_id, :integer

      timestamps()
    end

  end
end
