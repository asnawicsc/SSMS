defmodule School.Repo.Migrations.AddColorToSubject do
  use Ecto.Migration

  def change do
    alter table(:subject) do
      add(:color, :string)
    end
  end
end
