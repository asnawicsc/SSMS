defmodule School.Repo.Migrations.AddRemark2Toteacheratndecne do
  use Ecto.Migration

  def change do
 alter table("teacher_attendance") do
      add(:alasan, :string)
     
    end
  end
end
