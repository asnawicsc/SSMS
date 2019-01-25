defmodule School.Affairs.MarkSheetHistorys do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mark_sheet_historys" do
    field(:cdesc, :string)
    field(:class, :string)
    field(:cname, :string)
    field(:description, :string)
    field(:institution_id, :integer)
    field(:name, :string)
    field(:s1g, :string)
    field(:s1m, :string)
    field(:s2g, :string)
    field(:s2m, :string)
    field(:s3m, :string)
    field(:s3g, :string)
    field(:stuid, :string)
    field(:subject, :string)
    field(:t1g, :string)
    field(:t1m, :string)
    field(:t2g, :string)
    field(:t2m, :string)
    field(:t3g, :string)
    field(:t3m, :string)
    field(:t4g, :string)
    field(:t4m, :string)
    field(:t5g, :string)
    field(:t5m, :string)
    field(:t6g, :string)
    field(:t6m, :string)
    field(:year, :string)

    timestamps()
  end

  @doc false
  def changeset(mark_sheet_historys, attrs) do
    mark_sheet_historys
    |> cast(attrs, [
      :institution_id,
      :stuid,
      :name,
      :cname,
      :class,
      :subject,
      :description,
      :cdesc,
      :year,
      :t1m,
      :t2m,
      :t3m,
      :t4m,
      :t5m,
      :t6m,
      :s1m,
      :s2m,
      :s3m,
      :t1g,
      :t2g,
      :t3g,
      :t4g,
      :t5g,
      :t6g,
      :s1g,
      :s2g,
      :s3g
    ])
  end
end
