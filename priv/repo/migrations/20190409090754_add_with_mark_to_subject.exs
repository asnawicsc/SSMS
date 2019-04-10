defmodule School.Repo.Migrations.AddWithMarkToSubject do
  use Ecto.Migration

  def change do
 alter table("subject") do
      add(:with_mark, :integer)
     
    end
  end
end
