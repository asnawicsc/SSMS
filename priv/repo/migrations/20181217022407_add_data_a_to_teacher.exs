defmodule School.Repo.Migrations.AddDataAToTeacher do
  use Ecto.Migration

  def change do
    alter table("teacher") do
      add(:is_delete, :integer)
      add(:tranfer_in, :string)
      add(:tranfer_out, :string)
      add(:reason, :string)
    end
  end
end
