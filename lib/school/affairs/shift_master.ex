defmodule School.Affairs.ShiftMaster do
  use Ecto.Schema
  import Ecto.Changeset


  schema "shift_master" do
    field :day, :string
    field :end_time, :time
    field :institution_id, :integer
    field :name, :string
    field :semester_id, :integer
    field :start_time, :time

    timestamps()
  end

  @doc false
  def changeset(shift_master, attrs) do
    shift_master
    |> cast(attrs, [:name, :start_time, :end_time, :day, :semester_id, :institution_id])
    |> validate_required([:name, :start_time, :end_time, :day, :semester_id, :institution_id])
  end
end
