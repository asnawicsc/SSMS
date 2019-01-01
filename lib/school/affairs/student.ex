defmodule School.Affairs.Student do
  use Ecto.Schema
  import Ecto.Changeset
  require IEx

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
    field(:image_bin, :binary)
    field(:image_filename, :string)
    field(:register_date, :string)
    field(:quit_date, :string)

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
      :height,
      :image_bin,
      :image_filename,
      :register_date,
      :quit_date
    ])
    |> validate_required([:student_no])
    |> unique_constraint(:student_no)
    |> unique_constraint(:b_cert)
  end

  def delete_duplicate_student_no() do
    import Ecto.Query

    s_no =
      School.Repo.all(
        from(
          s in School.Affairs.Student,
          group_by: [s.student_no],
          select: %{ct: count(s.student_no), no: s.student_no}
        )
      )
      |> Enum.filter(fn x -> x.ct > 1 end)
      |> Enum.map(fn x -> x.no end)

    for s_n <- s_no do
      students = School.Repo.all(from(s in School.Affairs.Student, where: s.student_no == ^s_n))

      {student, dup_students} = List.pop_at(students, 0)
      Enum.map(dup_students, fn x -> School.Repo.delete(x) end)
    end
  end

  def delete_duplicate_student_name() do
    import Ecto.Query

    s_no =
      School.Repo.all(
        from(
          s in School.Affairs.Student,
          group_by: [s.name],
          select: %{ct: count(s.name), no: s.name}
        )
      )
      |> Enum.filter(fn x -> x.ct > 1 end)
      |> Enum.map(fn x -> x.no end)

    for s_n <- s_no do
      students = School.Repo.all(from(s in School.Affairs.Student, where: s.name == ^s_n))

      {student, dup_students} = List.pop_at(students, 0)

      Enum.map(dup_students, fn x ->
        School.Affairs.update_student(x, %{
          name: x.name <> "- duplicate - " <> Integer.to_string(x.id)
        })
      end)
    end
  end

  def delete_duplicate_student_id() do
    import Ecto.Query

    s_no =
      School.Repo.all(
        from(
          s in School.Affairs.Student,
          group_by: [s.name],
          select: %{ct: count(s.name), no: s.name}
        )
      )
      |> Enum.filter(fn x -> x.ct > 1 end)
      |> Enum.map(fn x -> x.no end)

    for s_n <- s_no do
      students = School.Repo.all(from(s in School.Affairs.Student, where: s.name == ^s_n))

      {student, dup_students} = List.pop_at(students, 0)

      Enum.map(dup_students, fn x ->
        School.Affairs.update_student(x, %{
          name: x.name <> "- duplicate - " <> Integer.to_string(x.id)
        })
      end)
    end
  end
end
