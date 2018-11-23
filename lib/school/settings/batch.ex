defmodule School.Settings.Batch do
  use Ecto.Schema
  import Ecto.Changeset


  schema "batches" do
    field :result, :binary
    field :upload_by, :integer

    timestamps()
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [:upload_by, :result])
    |> validate_required([:upload_by, :result])
  end
end
