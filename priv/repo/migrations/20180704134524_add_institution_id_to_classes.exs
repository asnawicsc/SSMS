defmodule School.Repo.Migrations.AddInstitutionIdToClasses do
  use Ecto.Migration

  def change do
  	alter table("classes") do
  		add :institution_id, :integer
  	end
  end
end
