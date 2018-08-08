defmodule School.Settings.Institution do
  use Ecto.Schema
  import Ecto.Changeset

  schema "institutions" do
    field(:country, :string)
    field(:email, :string)
    field(:email2, :string)
    field(:fax, :string)
    field(:line1, :string)
    field(:line2, :string)
    field(:logo_bin, :binary)
    field(:logo_filename, :string)
    field(:name, :string)
    field(:phone, :string)
    field(:phone2, :string)
    field(:postcode, :string)
    field(:state, :string)
    field(:town, :string)
    field(:maintained_by, :string)
    field(:library_organization_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(institution, attrs) do
    institution
    |> cast(attrs, [
      :library_organization_id,
      :name,
      :line1,
      :line2,
      :town,
      :postcode,
      :state,
      :country,
      :phone,
      :phone2,
      :email,
      :email2,
      :fax,
      :logo_bin,
      :logo_filename,
      :maintained_by
    ])
    |> validate_required([:name])
  end
end
