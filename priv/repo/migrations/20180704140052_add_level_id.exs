defmodule School.Repo.Migrations.AddLevelId do
  use Ecto.Migration

  def change do
  	alter table("classes") do
  		add :level_id, :integer
  	end
  end
end
