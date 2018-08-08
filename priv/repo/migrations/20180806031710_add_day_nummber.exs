defmodule School.Repo.Migrations.AddDayNummber do
  use Ecto.Migration

  def change do
  	 alter table(:day) do
      add :number, :integer

  end
end
end
