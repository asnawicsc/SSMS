defmodule School.Repo.Migrations.ChangeTeacher do
  use Ecto.Migration

  def change do
alter table("teacher") do
      remove(:is_delete)
    

      add(:is_delete, :boolean)
     
    end
  end
end
