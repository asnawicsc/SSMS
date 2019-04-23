defmodule School.Repo.Migrations.ChangeTotalBookNilam do
  use Ecto.Migration

  def change do
alter table("student_mark_nilam") do
     remove(:total_book_integer)
     
      add(:total_book, :integer)

end
  end
end
