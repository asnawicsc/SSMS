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
    field(:fb_user_id, :string)
    field(:role, :string, default: "Parent")
    field(:email, :string)
    field(:psid, :string)
    timestamps()
  end

  @doc false
  def changeset(parent, attrs) do
    parent
    |> cast(attrs, [
      :psid,
      :email,
      :role,
      :fb_user_id,
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
    |> validate_required([:icno])
    |> unique_constraint(:icno)
    |> unique_constraint(:icno)
  end

  def delete_duplicate_icno() do
    import Ecto.Query

    s_no =
      School.Repo.all(
        from(
          s in School.Affairs.Parent,
          group_by: [s.icno],
          select: %{ct: count(s.icno), no: s.icno}
        )
      )
      |> Enum.filter(fn x -> x.ct > 1 end)
      |> Enum.map(fn x -> x.no end)

    for s_n <- s_no do
      students = School.Repo.all(from(s in School.Affairs.Parent, where: s.icno == ^s_n))

      {student, dup_students} = List.pop_at(students, 0)
      Enum.map(dup_students, fn x -> School.Repo.delete(x) end)
    end
  end
end
