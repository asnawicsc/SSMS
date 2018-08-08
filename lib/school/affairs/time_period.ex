defmodule School.Affairs.TimePeriod do
  use Ecto.Schema
  import Ecto.Changeset


  schema "time_period" do
    field :time_end, :time
    field :time_start, :time

    timestamps()
  end

  @doc false
  def changeset(time_period, attrs) do
    time_period
    |> cast(attrs, [:time_start, :time_end])
    |> validate_required([:time_start, :time_end])
  end
end
