defmodule School.Affairs.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field(:blood_type, :string)
    field(:chinese_name, :string)
    field(:country, :string)
    field(:distance, :string)
    field(:dob, :string)
    field(:guardian_ids, :string)
    field(:ic, :string)
    field(:is_oku, :boolean, default: false)
    field(:line1, :string)
    field(:line2, :string)
    field(:name, :string)
    field(:nationality, :string)
    field(:oku_cat, :string)
    field(:oku_no, :string)
    field(:pass, :string)
    field(:phone, :string)
    field(:pob, :string)
    field(:position_in_house, :string)
    field(:postcode, :string)
    field(:race, :string)
    field(:religion, :string)
    field(:sex, :string)
    field(:state, :string)
    field(:subject_ids, :string)
    field(:town, :string)
    field(:transport, :string)
    field(:username, :string)
    field(:institution_id, :integer)
    field(:b_cert, :string)
    field(:achievements, :binary)
    field(:remarks, :binary)
    field(:student_no, :string)
    field(:guardtype, :string)
    field(:gicno, :string)
    field(:ficno, :string)
    field(:micno, :string)
    field(:height, :string)
    field(:weight, :string)
    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [
      :student_no,
      :b_cert,
      :remarks,
      :institution_id,
      :name,
      :chinese_name,
      :sex,
      :ic,
      :dob,
      :pob,
      :race,
      :religion,
      :nationality,
      :country,
      :line1,
      :line2,
      :postcode,
      :town,
      :state,
      :phone,
      :username,
      :pass,
      :is_oku,
      :oku_no,
      :oku_cat,
      :transport,
      :distance,
      :blood_type,
      :position_in_house,
      :guardian_ids,
      :subject_ids,
      :guardtype,
      :gicno,
      :ficno,
      :micno,
      :weight,
      :height
    ])
    |> validate_required([:student_no])
    |> unique_constraint(:b_cert)
  end
end
