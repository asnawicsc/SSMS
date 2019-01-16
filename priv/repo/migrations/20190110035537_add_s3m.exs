defmodule School.Repo.Migrations.AddS3m do
  use Ecto.Migration

  def change do
alter table("mark_sheet_historys") do
  
add(:s3m, :string)

end
  end
end
