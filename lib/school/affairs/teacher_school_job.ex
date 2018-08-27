defmodule School.Affairs.TeacherSchoolJob do
  use Ecto.Schema
  import Ecto.Changeset


  schema "teacher_school_job" do
    field :school_job_id, :integer
    field :semester_id, :integer
    field :teacher_id, :integer

    timestamps()
  end

  @doc false
  def changeset(teacher_school_job, attrs) do
    teacher_school_job
    |> cast(attrs, [:teacher_id, :school_job_id, :semester_id])
    |> validate_required([:teacher_id, :school_job_id, :semester_id])
  end
end
