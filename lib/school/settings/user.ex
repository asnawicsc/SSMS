defmodule School.Settings.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:crypted_password, :string)
    field(:institution_id, :integer)
    field(:name, :string)
    field(:password, :string)
    field(:role, :string, default: "Support")
    field(:email, :string)
    field(:default_lang, :string, default: "en")

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :default_lang,
      :email,
      :name,
      :password,
      :crypted_password,
      :institution_id,
      :role
    ])
    |> validate_required([:crypted_password, :email])
    |> unique_constraint(:email)
  end

  def institution_id(conn) do
    conn.private.plug_session["institution_id"]
  end
end
