defmodule School.Affairs.Comment do
  use Ecto.Schema
  import Ecto.Changeset


  schema "comment" do
    field :c_chinese, :string
    field :c_malay, :string
    field :code, :string

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:code, :c_chinese, :c_malay])
    |> validate_required([:code, :c_chinese, :c_malay])
  end
end
