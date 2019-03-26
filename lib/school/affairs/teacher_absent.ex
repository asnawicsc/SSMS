defmodule School.Affairs.TeacherAbsent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teacher_absent" do
    field(:alasan, :string)
    field(:date, :date)
    field(:institution_id, :integer)
    field(:month, :string)
    field(:remark, :string)
    field(:semester_id, :integer)
    field(:teacher_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(teacher_absent, attrs) do
    teacher_absent
    |> cast(attrs, [:institution_id, :semester_id, :teacher_id, :date, :remark, :month, :alasan])
    |> validate_required([
      :institution_id,
      :semester_id,
      :teacher_id,
      :date,
      :remark,
      :month,
      :alasan
    ])
  end
end
