defmodule School.Settings.UserAccess do
  use Ecto.Schema
  import Ecto.Changeset


  schema "user_access" do
    field :institution_id, :integer
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(user_access, attrs) do
    user_access
    |> cast(attrs, [:user_id, :institution_id])
    |> validate_required([:user_id, :institution_id])
  end
end
