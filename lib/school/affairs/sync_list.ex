defmodule School.Affairs.SyncList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sync_list" do
    field(:executed_time, :utc_datetime)
    field(:period_id, :integer)
    field(:status, :string, default: "unsync")

    timestamps()
  end

  @doc false
  def changeset(sync_list, attrs) do
    sync_list
    |> cast(attrs, [:period_id, :status, :executed_time])
    |> validate_required([:period_id])
  end
end
