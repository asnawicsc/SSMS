defmodule School.Setting.ContactUs do
  use Ecto.Schema
  import Ecto.Changeset


  schema "contact_us" do
    field :email, :string
    field :message, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(contact_us, attrs) do
    contact_us
    |> cast(attrs, [:name, :email, :message])
    |> validate_required([:name, :email, :message])
  end
end
