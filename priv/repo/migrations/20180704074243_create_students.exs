defmodule School.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :name, :string
      add :chinese_name, :string
      add :sex, :string
      add :ic, :string
      add :dob, :string
      add :pob, :string
      add :race, :string
      add :religion, :string
      add :nationality, :string
      add :country, :string
      add :line1, :string
      add :line2, :string
      add :postcode, :string
      add :town, :string
      add :state, :string
      add :phone, :string
      add :username, :string
      add :pass, :string
      add :is_oku, :boolean, default: false, null: false
      add :oku_no, :string
      add :oku_cat, :string
      add :transport, :string
      add :distance, :string
      add :blood_type, :string
      add :position_in_house, :string
      add :guardian_ids, :string
      add :subject_ids, :string

      timestamps()
    end

  end
end
