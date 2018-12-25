defmodule School.Affairs.Ediscipline do
  use Ecto.Schema
  import Ecto.Changeset

  schema "edisciplines" do
    field(:message, :binary)
    field(:psid, :string)
    field(:teacher_id, :integer)
    field(:title, :string)
    field(:summary, :binary)

    timestamps()
  end

  @doc false
  def changeset(ediscipline, attrs) do
    ediscipline
    |> cast(attrs, [:title, :message, :psid, :teacher_id, :summary])
    |> validate_required([:title, :message, :psid, :teacher_id])
  end
end
