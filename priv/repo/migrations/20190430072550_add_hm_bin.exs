defmodule School.Repo.Migrations.AddHmBin do
  use Ecto.Migration

  def change do
alter table("institutions") do
   
      add(:hm_bin, :binary)
         add(:hm_filename, :string)
end
  end
end
