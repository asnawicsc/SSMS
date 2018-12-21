defmodule School.Affairs.HistoryExam do
  use Ecto.Schema
  import Ecto.Changeset

  schema "history_exam" do
    field(:class_name, :string)
    field(:exam_class_rank, :integer)
    field(:exam_grade, :string)
    field(:exam_name, :string)
    field(:exam_standard_rank, :integer)
    field(:institution_id, :integer)
    field(:semester_id, :integer)
    field(:student_name, :string)
    field(:student_no, :integer)
    field(:subject_code, :string)
    field(:subject_mark, :decimal, default: 0.0)
    field(:subject_name, :string)
    field(:chinese_name, :string)
    field(:year, :integer)

    timestamps()
  end

  @doc false
  def changeset(history_exam, attrs) do
    history_exam
    |> cast(attrs, [
      :student_no,
      :student_name,
      :subject_name,
      :subject_code,
      :subject_mark,
      :exam_class_rank,
      :exam_standard_rank,
      :exam_name,
      :class_name,
      :semester_id,
      :institution_id,
      :exam_grade,
      :chinese_name,
      :year
    ])
  end
end
