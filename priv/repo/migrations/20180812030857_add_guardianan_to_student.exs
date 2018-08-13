defmodule School.Repo.Migrations.AddGuardiananToStudent do
  use Ecto.Migration

  def change do
  	alter table("students") do
      add(:guardtype, :string)
      add(:gicno, :string)
      add(:ficno, :string)
      add(:micno, :string)
    end

  end
end
