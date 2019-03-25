defmodule School.Affairs.TeacherAttendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teacher_attendance" do
    field(:institution_id, :integer)
    field(:semester_id, :integer)
    field(:teacher_id, :integer)
    field(:time_in, :string)
    field(:time_out, :string)
    field(:date, :string)
    field(:remark, :string)
    field(:month, :string)

    timestamps()
  end

  @doc false
  def changeset(teacher_attendance, attrs) do
    teacher_attendance
    |> cast(attrs, [
      :month,
      :remark,
      :institution_id,
      :teacher_id,
      :semester_id,
      :time_in,
      :time_out,
      :date
    ])
    |> validate_required([:institution_id, :teacher_id, :semester_id])
  end
end
