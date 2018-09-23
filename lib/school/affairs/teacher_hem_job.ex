defmodule School.Affairs.TeacherHemJob do
  use Ecto.Schema
  import Ecto.Changeset


  schema "teacher_hem_job" do
    field :hem_job_id, :integer
    field :semester_id, :integer
    field :teacher_id, :integer
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(teacher_hem_job, attrs) do
    teacher_hem_job
    |> cast(attrs, [:institution_id, :teacher_id, :hem_job_id, :semester_id])
    |> validate_required([:institution_id, :teacher_id, :hem_job_id, :semester_id])
  end
end
