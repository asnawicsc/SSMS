defmodule School.Affairs.AbsentHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "absent_history" do
    field(:absent_date, :string)
    field(:absent_type, :string)
    field(:chinese_name, :string)
    field(:student_class, :string)
    field(:student_name, :string)
    field(:student_no, :integer)
    field(:year, :integer)
    field(:institution_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(absent_history, attrs) do
    absent_history
    |> cast(attrs, [
      :institution_id,
      :student_no,
      :student_name,
      :chinese_name,
      :student_class,
      :absent_date,
      :absent_type,
      :year
    ])
  end
end
