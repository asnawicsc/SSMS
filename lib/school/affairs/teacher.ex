defmodule School.Affairs.Teacher do
  use Ecto.Schema
  import Ecto.Changeset


  schema "teacher" do
    field :education, :string
    field :qrem, :string
    field :religion, :string
    field :district, :string
    field :gid, :string
    field :cname, :string
    field :bdate, :string
    field :sex, :string
    field :addr2, :string
    field :race, :string
    field :tscjob6, :string
    field :code, :string
    field :regdate, :string
    field :tccjob1, :string
    field :poscod, :string
    field :tccjob3, :string
    field :secondid, :string
    field :postitle, :string
    field :tscjob2, :string
    field :bcenrlno, :string
    field :job, :string
    field :tscjob3, :string
    field :state, :string
    field :tscjob5, :string
    field :tel, :string
    field :addr1, :string
    field :qdate, :string
    field :tchtype, :string
    field :remark, :string
    field :tccjob5, :string
    field :tccjob2, :string
    field :session, :string
    field :name, :string
    field :tccjob4, :string
    field :tscjob1, :string
    field :nation, :string
    field :addr3, :string
    field :icno, :string
    field :tscjob4, :string
    field :tccjob6, :string
    field :institution_id, :integer

    timestamps()
  end

  @doc false
  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, [:institution_id, :code, :name, :cname, :icno, :sex, :race, :religion, :nation, :bdate, :addr1, :addr2, :addr3, :poscod, :district, :state, :tel, :regdate, :qdate, :qrem, :postitle, :job, :education, :remark, :secondid, :tchtype, :gid, :session, :bcenrlno, :tscjob1, :tscjob2, :tscjob3, :tscjob4, :tscjob5, :tscjob6, :tccjob1, :tccjob2, :tccjob3, :tccjob4, :tccjob5, :tccjob6])
   
  end
end
