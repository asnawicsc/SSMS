defmodule School.Affairs.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcements" do
    field(:message, :binary)
    field(:institution_id, :integer)
    timestamps()
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:message, :institution_id])
    |> validate_required([:message])
  end
end
