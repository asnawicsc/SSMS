defmodule School.Affairs.Shift do
  use Ecto.Schema
  import Ecto.Changeset


  schema "shift" do
    field :shift_master_id, :integer
    field :teacher_id, :integer

    timestamps()
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [:teacher_id, :shift_master_id])
    |> validate_required([:teacher_id, :shift_master_id])
  end
end
