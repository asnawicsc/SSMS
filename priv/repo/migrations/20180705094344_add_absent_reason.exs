defmodule School.Repo.Migrations.AddAbsentReason do
  use Ecto.Migration

  def change do
  	alter table("parameters") do
  		add :absent_reasons, :binary
  	end
  end
end
