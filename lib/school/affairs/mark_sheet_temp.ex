defmodule School.Affairs.MarkSheetTemp do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mark_sheet_temp" do
    field(:cdesc, :string)
    field(:class, :string)
    field(:cname, :string)
    field(:description, :string)
    field(:institution_id, :integer)
    field(:exam_name, :string)
    field(:name, :string)
    field(:s1g, :string)
    field(:s1m, :string)
    field(:s2g, :string)
    field(:s2m, :string)
    field(:s3g, :string)
    field(:s3m, :string)
    field(:semester, :string)
    field(:stuid, :string)
    field(:subject, :string)
    field(:year, :string)

    timestamps()
  end

  @doc false
  def changeset(mark_sheet_temp, attrs) do
    mark_sheet_temp
    |> cast(attrs, [
      :exam_name,
      :institution_id,
      :stuid,
      :name,
      :cname,
      :class,
      :subject,
      :description,
      :cdesc,
      :year,
      :semester,
      :s1m,
      :s2m,
      :s3m,
      :s1g,
      :s2g,
      :s3g
    ])
    |> validate_required([
      :institution_id,
      :stuid,
      :name,
      :cname,
      :class,
      :subject,
      :description,
      :year
    ])
  end
end
