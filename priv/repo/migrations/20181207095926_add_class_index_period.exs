defmodule School.Repo.Migrations.AddClassIndexPeriod do
  use Ecto.Migration

  def down do
    drop(
      index(
        :period,
        [:start_datetime],
        name: :index_all_s_c
      )
    )
  end

  def up do
    drop_if_exists(
      index(
        :period,
        [:start_datetime],
        name: :index_all_s_c
      )
    )

    create(
      unique_index(
        :period,
        [:start_datetime, :end_datetime, :class_id],
        name: :index_all_s_c
      )
    )
  end
end
