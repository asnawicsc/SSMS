defmodule School.Repo.Migrations.AddIndexCalender do
  use Ecto.Migration

  def change do
    create(
      unique_index(
        :period,
        [:start_datetime, :end_datetime, :class_id, :subject_id],
        name: :index_all_s_c
      )
    )
  end
end
