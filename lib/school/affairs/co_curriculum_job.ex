defmodule School.Affairs.CoCurriculumJob do
  use Ecto.Schema
  import Ecto.Changeset


  schema "cocurriculum_job" do
    field :cdesc, :string
    field :code, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(co_curriculum_job, attrs) do
    co_curriculum_job
    |> cast(attrs, [:code, :description, :cdesc])
  end
end
