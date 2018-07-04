defmodule School.Settings.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :crypted_password, :string
    field :institution_id, :integer
    field :name, :string
    field :password, :string
    field :role, :string, default: "Support"
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :crypted_password, :institution_id, :role])
    |> validate_required([ :crypted_password, :email])
  end
end
