defmodule School.Affairs.TeacherCoCurriculumJob do
  use Ecto.Schema
  import Ecto.Changeset


  schema "teacher_co_curriculum_job" do
    field :co_curriculum_job_id, :integer
    field :semester_id, :integer
    field :teacher_id, :integer

    timestamps()
  end

  @doc false
  def changeset(teacher_co_curriculum_job, attrs) do
    teacher_co_curriculum_job
    |> cast(attrs, [:teacher_id, :co_curriculum_job_id, :semester_id])
    |> validate_required([:teacher_id, :co_curriculum_job_id, :semester_id])
  end
end
