defmodule School.Repo.Migrations.AddUniqueIndexStc do
  use Ecto.Migration

  def change do
    create(
      unique_index(
        :subject_teach_class,
        [:standard_id, :subject_id, :class_id, :institution_id],
        name: :index_all_stc
      )
    )
  end
end
