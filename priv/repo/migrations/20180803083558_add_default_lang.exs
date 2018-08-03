defmodule School.Repo.Migrations.AddDefaultLang do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:default_lang, :string, default: "en")
    end
  end
end
