defmodule School.Repo.Migrations.AddShiftGroup do
  use Ecto.Migration
 def change do
   alter table("shift_master") do
      add(:shift_group, :string)
     end
    end
end
