defmodule School.Affairs.Parent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parent" do
    field(:addr1, :string)
    field(:addr2, :string)
    field(:addr3, :string)
    field(:cname, :string)
    field(:country, :string)
    field(:district, :string)
    field(:epaddr1, :string)
    field(:epaddr2, :string)
    field(:epaddr3, :string)
    field(:epdistrict, :string)
    field(:epname, :string)
    field(:epposcod, :string)
    field(:epstate, :string)
    field(:hphone, :string)
    field(:htel, :string)
    field(:icno, :string)
    field(:income, :string)
    field(:inctaxno, :string)
    field(:nacert, :string)
    field(:name, :string)
    field(:nation, :string)
    field(:occup, :string)
    field(:oldic, :string)
    field(:otel, :string)
    field(:poscod, :string)
    field(:pstatus, :string)
    field(:race, :string)
    field(:refno, :string)
    field(:relation, :string)
    field(:religion, :string)
    field(:state, :string)
    field(:tanggn, :string)
    field(:institution_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(parent, attrs) do
    parent
    |> cast(attrs, [
      :institution_id,
      :icno,
      :name,
      :cname,
      :relation,
      :race,
      :religion,
      :nation,
      :country,
      :nacert,
      :pstatus,
      :tanggn,
      :oldic,
      :refno,
      :occup,
      :income,
      :addr1,
      :addr2,
      :addr3,
      :poscod,
      :district,
      :state,
      :htel,
      :otel,
      :hphone,
      :epname,
      :epaddr1,
      :epaddr2,
      :epaddr3,
      :epposcod,
      :epdistrict,
      :epstate,
      :inctaxno
    ])
  end
end
