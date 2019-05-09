defmodule School.Affairs.CoCurriculum do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cocurriculum" do
    field(:code, :string)
    field(:description, :string)
    field(:institution_id, :integer)
    field(:teacher_id, :integer)
    field(:category, :string)
    field(:sub_category, :string)
    field(:student_id, :integer)
    field(:class_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(co_curriculum, attrs) do
    co_curriculum
    |> cast(attrs, [:teacher_id, :institution_id, :code, :description, :category, :sub_category])
  end
end
