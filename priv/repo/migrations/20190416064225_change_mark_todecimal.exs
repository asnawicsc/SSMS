defmodule School.Repo.Migrations.ChangeMarkTodecimal do
  use Ecto.Migration

  def change do
alter table("exam_mark") do
	      remove(:mark)
      add(:mark, :decimal)

 
  end
  end
end
