defmodule School.Repo.Migrations.AddInstIdToStudent do
  use Ecto.Migration

  def change do
  	alter table("students") do
  		add :institution_id, :integer
  	end
  end
end
