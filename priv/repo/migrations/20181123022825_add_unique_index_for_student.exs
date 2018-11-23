defmodule School.Repo.Migrations.AddUniqueIndexForStudent do
  use Ecto.Migration

  def change do
    create(
      unique_index(
        :students,
        :b_cert
      )
    )
  end
end
