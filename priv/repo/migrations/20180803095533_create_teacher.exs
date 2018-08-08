defmodule School.Repo.Migrations.CreateTeacher do
  use Ecto.Migration

  def change do
    create table(:teacher) do
      add :code, :string
      add :name, :string
      add :cname, :string
      add :icno, :string
      add :sex, :string
      add :race, :string
      add :religion, :string
      add :nation, :string
      add :bdate, :string
      add :addr1, :string
      add :addr2, :string
      add :addr3, :string
      add :poscod, :string
      add :district, :string
      add :state, :string
      add :tel, :string
      add :regdate, :string
      add :qdate, :string
      add :qrem, :string
      add :postitle, :string
      add :job, :string
      add :education, :string
      add :remark, :string
      add :secondid, :string
      add :tchtype, :string
      add :gid, :string
      add :session, :string
      add :bcenrlno, :string
      add :tscjob1, :string
      add :tscjob2, :string
      add :tscjob3, :string
      add :tscjob4, :string
      add :tscjob5, :string
      add :tscjob6, :string
      add :tccjob1, :string
      add :tccjob2, :string
      add :tccjob3, :string
      add :tccjob4, :string
      add :tccjob5, :string
      add :tccjob6, :string

      timestamps()
    end

  end
end
