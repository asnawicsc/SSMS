defmodule School.Repo.Migrations.CreateParent do
  use Ecto.Migration

  def change do
    create table(:parent) do
      add :icno, :string
      add :name, :string
      add :cname, :string
      add :relation, :string
      add :race, :string
      add :religion, :string
      add :nation, :string
      add :country, :string
      add :nacert, :string
      add :pstatus, :string
      add :tanggn, :string
      add :oldic, :string
      add :refno, :string
      add :occup, :string
      add :income, :string
      add :addr1, :string
      add :addr2, :string
      add :addr3, :string
      add :poscod, :string
      add :district, :string
      add :state, :string
      add :htel, :string
      add :otel, :string
      add :hphone, :string
      add :epname, :string
      add :epaddr1, :string
      add :epaddr2, :string
      add :epaddr3, :string
      add :epposcod, :string
      add :epdistrict, :string
      add :epstate, :string
      add :inctaxno, :string

      timestamps()
    end

  end
end
