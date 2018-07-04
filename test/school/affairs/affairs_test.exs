defmodule School.AffairsTest do
  use School.DataCase

  alias School.Affairs

  describe "students" do
    alias School.Affairs.Student

    @valid_attrs %{blood_type: "some blood_type", chinese_name: "some chinese_name", country: "some country", distance: "some distance", dob: "some dob", guardian_ids: "some guardian_ids", ic: "some ic", is_oku: true, line1: "some line1", line2: "some line2", name: "some name", nationality: "some nationality", oku_cat: "some oku_cat", oku_no: "some oku_no", pass: "some pass", phone: "some phone", pob: "some pob", position_in_house: "some position_in_house", postcode: "some postcode", race: "some race", religion: "some religion", sex: "some sex", state: "some state", subject_ids: "some subject_ids", town: "some town", transport: "some transport", username: "some username"}
    @update_attrs %{blood_type: "some updated blood_type", chinese_name: "some updated chinese_name", country: "some updated country", distance: "some updated distance", dob: "some updated dob", guardian_ids: "some updated guardian_ids", ic: "some updated ic", is_oku: false, line1: "some updated line1", line2: "some updated line2", name: "some updated name", nationality: "some updated nationality", oku_cat: "some updated oku_cat", oku_no: "some updated oku_no", pass: "some updated pass", phone: "some updated phone", pob: "some updated pob", position_in_house: "some updated position_in_house", postcode: "some updated postcode", race: "some updated race", religion: "some updated religion", sex: "some updated sex", state: "some updated state", subject_ids: "some updated subject_ids", town: "some updated town", transport: "some updated transport", username: "some updated username"}
    @invalid_attrs %{blood_type: nil, chinese_name: nil, country: nil, distance: nil, dob: nil, guardian_ids: nil, ic: nil, is_oku: nil, line1: nil, line2: nil, name: nil, nationality: nil, oku_cat: nil, oku_no: nil, pass: nil, phone: nil, pob: nil, position_in_house: nil, postcode: nil, race: nil, religion: nil, sex: nil, state: nil, subject_ids: nil, town: nil, transport: nil, username: nil}

    def student_fixture(attrs \\ %{}) do
      {:ok, student} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_student()

      student
    end

    test "list_students/0 returns all students" do
      student = student_fixture()
      assert Affairs.list_students() == [student]
    end

    test "get_student!/1 returns the student with given id" do
      student = student_fixture()
      assert Affairs.get_student!(student.id) == student
    end

    test "create_student/1 with valid data creates a student" do
      assert {:ok, %Student{} = student} = Affairs.create_student(@valid_attrs)
      assert student.blood_type == "some blood_type"
      assert student.chinese_name == "some chinese_name"
      assert student.country == "some country"
      assert student.distance == "some distance"
      assert student.dob == "some dob"
      assert student.guardian_ids == "some guardian_ids"
      assert student.ic == "some ic"
      assert student.is_oku == true
      assert student.line1 == "some line1"
      assert student.line2 == "some line2"
      assert student.name == "some name"
      assert student.nationality == "some nationality"
      assert student.oku_cat == "some oku_cat"
      assert student.oku_no == "some oku_no"
      assert student.pass == "some pass"
      assert student.phone == "some phone"
      assert student.pob == "some pob"
      assert student.position_in_house == "some position_in_house"
      assert student.postcode == "some postcode"
      assert student.race == "some race"
      assert student.religion == "some religion"
      assert student.sex == "some sex"
      assert student.state == "some state"
      assert student.subject_ids == "some subject_ids"
      assert student.town == "some town"
      assert student.transport == "some transport"
      assert student.username == "some username"
    end

    test "create_student/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_student(@invalid_attrs)
    end

    test "update_student/2 with valid data updates the student" do
      student = student_fixture()
      assert {:ok, student} = Affairs.update_student(student, @update_attrs)
      assert %Student{} = student
      assert student.blood_type == "some updated blood_type"
      assert student.chinese_name == "some updated chinese_name"
      assert student.country == "some updated country"
      assert student.distance == "some updated distance"
      assert student.dob == "some updated dob"
      assert student.guardian_ids == "some updated guardian_ids"
      assert student.ic == "some updated ic"
      assert student.is_oku == false
      assert student.line1 == "some updated line1"
      assert student.line2 == "some updated line2"
      assert student.name == "some updated name"
      assert student.nationality == "some updated nationality"
      assert student.oku_cat == "some updated oku_cat"
      assert student.oku_no == "some updated oku_no"
      assert student.pass == "some updated pass"
      assert student.phone == "some updated phone"
      assert student.pob == "some updated pob"
      assert student.position_in_house == "some updated position_in_house"
      assert student.postcode == "some updated postcode"
      assert student.race == "some updated race"
      assert student.religion == "some updated religion"
      assert student.sex == "some updated sex"
      assert student.state == "some updated state"
      assert student.subject_ids == "some updated subject_ids"
      assert student.town == "some updated town"
      assert student.transport == "some updated transport"
      assert student.username == "some updated username"
    end

    test "update_student/2 with invalid data returns error changeset" do
      student = student_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_student(student, @invalid_attrs)
      assert student == Affairs.get_student!(student.id)
    end

    test "delete_student/1 deletes the student" do
      student = student_fixture()
      assert {:ok, %Student{}} = Affairs.delete_student(student)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_student!(student.id) end
    end

    test "change_student/1 returns a student changeset" do
      student = student_fixture()
      assert %Ecto.Changeset{} = Affairs.change_student(student)
    end
  end

  describe "levels" do
    alias School.Affairs.Level

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def level_fixture(attrs \\ %{}) do
      {:ok, level} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_level()

      level
    end

    test "list_levels/0 returns all levels" do
      level = level_fixture()
      assert Affairs.list_levels() == [level]
    end

    test "get_level!/1 returns the level with given id" do
      level = level_fixture()
      assert Affairs.get_level!(level.id) == level
    end

    test "create_level/1 with valid data creates a level" do
      assert {:ok, %Level{} = level} = Affairs.create_level(@valid_attrs)
      assert level.name == "some name"
    end

    test "create_level/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_level(@invalid_attrs)
    end

    test "update_level/2 with valid data updates the level" do
      level = level_fixture()
      assert {:ok, level} = Affairs.update_level(level, @update_attrs)
      assert %Level{} = level
      assert level.name == "some updated name"
    end

    test "update_level/2 with invalid data returns error changeset" do
      level = level_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_level(level, @invalid_attrs)
      assert level == Affairs.get_level!(level.id)
    end

    test "delete_level/1 deletes the level" do
      level = level_fixture()
      assert {:ok, %Level{}} = Affairs.delete_level(level)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_level!(level.id) end
    end

    test "change_level/1 returns a level changeset" do
      level = level_fixture()
      assert %Ecto.Changeset{} = Affairs.change_level(level)
    end
  end

  describe "semesters" do
    alias School.Affairs.Semester

    @valid_attrs %{end_date: ~D[2010-04-17], holiday_end: ~D[2010-04-17], holiday_start: ~D[2010-04-17], school_days: 42, start_date: ~D[2010-04-17]}
    @update_attrs %{end_date: ~D[2011-05-18], holiday_end: ~D[2011-05-18], holiday_start: ~D[2011-05-18], school_days: 43, start_date: ~D[2011-05-18]}
    @invalid_attrs %{end_date: nil, holiday_end: nil, holiday_start: nil, school_days: nil, start_date: nil}

    def semester_fixture(attrs \\ %{}) do
      {:ok, semester} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_semester()

      semester
    end

    test "list_semesters/0 returns all semesters" do
      semester = semester_fixture()
      assert Affairs.list_semesters() == [semester]
    end

    test "get_semester!/1 returns the semester with given id" do
      semester = semester_fixture()
      assert Affairs.get_semester!(semester.id) == semester
    end

    test "create_semester/1 with valid data creates a semester" do
      assert {:ok, %Semester{} = semester} = Affairs.create_semester(@valid_attrs)
      assert semester.end_date == ~D[2010-04-17]
      assert semester.holiday_end == ~D[2010-04-17]
      assert semester.holiday_start == ~D[2010-04-17]
      assert semester.school_days == 42
      assert semester.start_date == ~D[2010-04-17]
    end

    test "create_semester/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_semester(@invalid_attrs)
    end

    test "update_semester/2 with valid data updates the semester" do
      semester = semester_fixture()
      assert {:ok, semester} = Affairs.update_semester(semester, @update_attrs)
      assert %Semester{} = semester
      assert semester.end_date == ~D[2011-05-18]
      assert semester.holiday_end == ~D[2011-05-18]
      assert semester.holiday_start == ~D[2011-05-18]
      assert semester.school_days == 43
      assert semester.start_date == ~D[2011-05-18]
    end

    test "update_semester/2 with invalid data returns error changeset" do
      semester = semester_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_semester(semester, @invalid_attrs)
      assert semester == Affairs.get_semester!(semester.id)
    end

    test "delete_semester/1 deletes the semester" do
      semester = semester_fixture()
      assert {:ok, %Semester{}} = Affairs.delete_semester(semester)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_semester!(semester.id) end
    end

    test "change_semester/1 returns a semester changeset" do
      semester = semester_fixture()
      assert %Ecto.Changeset{} = Affairs.change_semester(semester)
    end
  end

  describe "classes" do
    alias School.Affairs.Class

    @valid_attrs %{name: "some name", remarks: "some remarks"}
    @update_attrs %{name: "some updated name", remarks: "some updated remarks"}
    @invalid_attrs %{name: nil, remarks: nil}

    def class_fixture(attrs \\ %{}) do
      {:ok, class} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_class()

      class
    end

    test "list_classes/0 returns all classes" do
      class = class_fixture()
      assert Affairs.list_classes() == [class]
    end

    test "get_class!/1 returns the class with given id" do
      class = class_fixture()
      assert Affairs.get_class!(class.id) == class
    end

    test "create_class/1 with valid data creates a class" do
      assert {:ok, %Class{} = class} = Affairs.create_class(@valid_attrs)
      assert class.name == "some name"
      assert class.remarks == "some remarks"
    end

    test "create_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_class(@invalid_attrs)
    end

    test "update_class/2 with valid data updates the class" do
      class = class_fixture()
      assert {:ok, class} = Affairs.update_class(class, @update_attrs)
      assert %Class{} = class
      assert class.name == "some updated name"
      assert class.remarks == "some updated remarks"
    end

    test "update_class/2 with invalid data returns error changeset" do
      class = class_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_class(class, @invalid_attrs)
      assert class == Affairs.get_class!(class.id)
    end

    test "delete_class/1 deletes the class" do
      class = class_fixture()
      assert {:ok, %Class{}} = Affairs.delete_class(class)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_class!(class.id) end
    end

    test "change_class/1 returns a class changeset" do
      class = class_fixture()
      assert %Ecto.Changeset{} = Affairs.change_class(class)
    end
  end

  describe "student_classes" do
    alias School.Affairs.StudentClass

    @valid_attrs %{class_id: 42, institute_id: 42, level_id: 42, semester_id: 42, sudent_id: 42}
    @update_attrs %{class_id: 43, institute_id: 43, level_id: 43, semester_id: 43, sudent_id: 43}
    @invalid_attrs %{class_id: nil, institute_id: nil, level_id: nil, semester_id: nil, sudent_id: nil}

    def student_class_fixture(attrs \\ %{}) do
      {:ok, student_class} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_student_class()

      student_class
    end

    test "list_student_classes/0 returns all student_classes" do
      student_class = student_class_fixture()
      assert Affairs.list_student_classes() == [student_class]
    end

    test "get_student_class!/1 returns the student_class with given id" do
      student_class = student_class_fixture()
      assert Affairs.get_student_class!(student_class.id) == student_class
    end

    test "create_student_class/1 with valid data creates a student_class" do
      assert {:ok, %StudentClass{} = student_class} = Affairs.create_student_class(@valid_attrs)
      assert student_class.class_id == 42
      assert student_class.institute_id == 42
      assert student_class.level_id == 42
      assert student_class.semester_id == 42
      assert student_class.sudent_id == 42
    end

    test "create_student_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_student_class(@invalid_attrs)
    end

    test "update_student_class/2 with valid data updates the student_class" do
      student_class = student_class_fixture()
      assert {:ok, student_class} = Affairs.update_student_class(student_class, @update_attrs)
      assert %StudentClass{} = student_class
      assert student_class.class_id == 43
      assert student_class.institute_id == 43
      assert student_class.level_id == 43
      assert student_class.semester_id == 43
      assert student_class.sudent_id == 43
    end

    test "update_student_class/2 with invalid data returns error changeset" do
      student_class = student_class_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_student_class(student_class, @invalid_attrs)
      assert student_class == Affairs.get_student_class!(student_class.id)
    end

    test "delete_student_class/1 deletes the student_class" do
      student_class = student_class_fixture()
      assert {:ok, %StudentClass{}} = Affairs.delete_student_class(student_class)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_student_class!(student_class.id) end
    end

    test "change_student_class/1 returns a student_class changeset" do
      student_class = student_class_fixture()
      assert %Ecto.Changeset{} = Affairs.change_student_class(student_class)
    end
  end
end
