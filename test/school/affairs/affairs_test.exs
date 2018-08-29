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

  describe "attendance" do
    alias School.Affairs.Attendance

    @valid_attrs %{attendance_date: ~D[2010-04-17], class_id: 42, institution_id: 42, mark_by: "some mark_by", semester_id: 42, student_id: 42}
    @update_attrs %{attendance_date: ~D[2011-05-18], class_id: 43, institution_id: 43, mark_by: "some updated mark_by", semester_id: 43, student_id: 43}
    @invalid_attrs %{attendance_date: nil, class_id: nil, institution_id: nil, mark_by: nil, semester_id: nil, student_id: nil}

    def attendance_fixture(attrs \\ %{}) do
      {:ok, attendance} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_attendance()

      attendance
    end

    test "list_attendance/0 returns all attendance" do
      attendance = attendance_fixture()
      assert Affairs.list_attendance() == [attendance]
    end

    test "get_attendance!/1 returns the attendance with given id" do
      attendance = attendance_fixture()
      assert Affairs.get_attendance!(attendance.id) == attendance
    end

    test "create_attendance/1 with valid data creates a attendance" do
      assert {:ok, %Attendance{} = attendance} = Affairs.create_attendance(@valid_attrs)
      assert attendance.attendance_date == ~D[2010-04-17]
      assert attendance.class_id == 42
      assert attendance.institution_id == 42
      assert attendance.mark_by == "some mark_by"
      assert attendance.semester_id == 42
      assert attendance.student_id == 42
    end

    test "create_attendance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_attendance(@invalid_attrs)
    end

    test "update_attendance/2 with valid data updates the attendance" do
      attendance = attendance_fixture()
      assert {:ok, attendance} = Affairs.update_attendance(attendance, @update_attrs)
      assert %Attendance{} = attendance
      assert attendance.attendance_date == ~D[2011-05-18]
      assert attendance.class_id == 43
      assert attendance.institution_id == 43
      assert attendance.mark_by == "some updated mark_by"
      assert attendance.semester_id == 43
      assert attendance.student_id == 43
    end

    test "update_attendance/2 with invalid data returns error changeset" do
      attendance = attendance_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_attendance(attendance, @invalid_attrs)
      assert attendance == Affairs.get_attendance!(attendance.id)
    end

    test "delete_attendance/1 deletes the attendance" do
      attendance = attendance_fixture()
      assert {:ok, %Attendance{}} = Affairs.delete_attendance(attendance)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_attendance!(attendance.id) end
    end

    test "change_attendance/1 returns a attendance changeset" do
      attendance = attendance_fixture()
      assert %Ecto.Changeset{} = Affairs.change_attendance(attendance)
    end
  end

  describe "absent" do
    alias School.Affairs.Absent

    @valid_attrs %{absent_date: ~D[2010-04-17], reason: "some reason", student_id: 42}
    @update_attrs %{absent_date: ~D[2011-05-18], reason: "some updated reason", student_id: 43}
    @invalid_attrs %{absent_date: nil, reason: nil, student_id: nil}

    def absent_fixture(attrs \\ %{}) do
      {:ok, absent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_absent()

      absent
    end

    test "list_absent/0 returns all absent" do
      absent = absent_fixture()
      assert Affairs.list_absent() == [absent]
    end

    test "get_absent!/1 returns the absent with given id" do
      absent = absent_fixture()
      assert Affairs.get_absent!(absent.id) == absent
    end

    test "create_absent/1 with valid data creates a absent" do
      assert {:ok, %Absent{} = absent} = Affairs.create_absent(@valid_attrs)
      assert absent.absent_date == ~D[2010-04-17]
      assert absent.reason == "some reason"
      assert absent.student_id == 42
    end

    test "create_absent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_absent(@invalid_attrs)
    end

    test "update_absent/2 with valid data updates the absent" do
      absent = absent_fixture()
      assert {:ok, absent} = Affairs.update_absent(absent, @update_attrs)
      assert %Absent{} = absent
      assert absent.absent_date == ~D[2011-05-18]
      assert absent.reason == "some updated reason"
      assert absent.student_id == 43
    end

    test "update_absent/2 with invalid data returns error changeset" do
      absent = absent_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_absent(absent, @invalid_attrs)
      assert absent == Affairs.get_absent!(absent.id)
    end

    test "delete_absent/1 deletes the absent" do
      absent = absent_fixture()
      assert {:ok, %Absent{}} = Affairs.delete_absent(absent)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_absent!(absent.id) end
    end

    test "change_absent/1 returns a absent changeset" do
      absent = absent_fixture()
      assert %Ecto.Changeset{} = Affairs.change_absent(absent)
    end
  end

  describe "teacher" do
    alias School.Affairs.Teacher

    @valid_attrs %{tscjob4: "some tscjob4", icno: "some icno", addr3: "some addr3", nation: "some nation", tscjob1: "some tscjob1", name: "some name", session: "some session", remark: "some remark", tchtype: "some tchtype", qdate: "some qdate", addr1: "some addr1", tel: "some tel", tscjob5: "some tscjob5", state: "some state", tscjob3: "some tscjob3", job: "some job", bcenrlno: "some bcenrlno", tscjob2: "some tscjob2", postitle: "some postitle", secondid: "some secondid", poscod: "some poscod", regdate: "some regdate", code: "some code", tscjob6: "some tscjob6", race: "some race", addr2: "some addr2", sex: "some sex", bdate: "some bdate", cname: "some cname", gid: "some gid", district: "some district", religion: "some religion", qrem: "some qrem", education: "some education"}
    @update_attrs %{tscjob4: "some updated tscjob4", icno: "some updated icno", addr3: "some updated addr3", nation: "some updated nation", tscjob1: "some updated tscjob1", name: "some updated name", session: "some updated session", remark: "some updated remark", tchtype: "some updated tchtype", qdate: "some updated qdate", addr1: "some updated addr1", tel: "some updated tel", tscjob5: "some updated tscjob5", state: "some updated state", tscjob3: "some updated tscjob3", job: "some updated job", bcenrlno: "some updated bcenrlno", tscjob2: "some updated tscjob2", postitle: "some updated postitle", secondid: "some updated secondid", poscod: "some updated poscod", regdate: "some updated regdate", code: "some updated code", tscjob6: "some updated tscjob6", race: "some updated race", addr2: "some updated addr2", sex: "some updated sex", bdate: "some updated bdate", cname: "some updated cname", gid: "some updated gid", district: "some updated district", religion: "some updated religion", qrem: "some updated qrem", education: "some updated education"}
    @invalid_attrs %{tscjob4: nil, icno: nil, addr3: nil, nation: nil, tscjob1: nil, name: nil, session: nil, remark: nil, tchtype: nil, qdate: nil, addr1: nil, tel: nil, tscjob5: nil, state: nil, tscjob3: nil, job: nil, bcenrlno: nil, tscjob2: nil, postitle: nil, secondid: nil, poscod: nil, regdate: nil, code: nil, tscjob6: nil, race: nil, addr2: nil, sex: nil, bdate: nil, cname: nil, gid: nil, district: nil, religion: nil, qrem: nil, education: nil}

    def teacher_fixture(attrs \\ %{}) do
      {:ok, teacher} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher()

      teacher
    end

    test "list_teacher/0 returns all teacher" do
      teacher = teacher_fixture()
      assert Affairs.list_teacher() == [teacher]
    end

    test "get_teacher!/1 returns the teacher with given id" do
      teacher = teacher_fixture()
      assert Affairs.get_teacher!(teacher.id) == teacher
    end

    test "create_teacher/1 with valid data creates a teacher" do
      assert {:ok, %Teacher{} = teacher} = Affairs.create_teacher(@valid_attrs)
      assert teacher.education == "some education"
      assert teacher.qrem == "some qrem"
      assert teacher.religion == "some religion"
      assert teacher.district == "some district"
      assert teacher.gid == "some gid"
      assert teacher.cname == "some cname"
      assert teacher.bdate == "some bdate"
      assert teacher.sex == "some sex"
      assert teacher.addr2 == "some addr2"
      assert teacher.race == "some race"
      assert teacher.tscjob6 == "some tscjob6"
      assert teacher.code == "some code"
      assert teacher.regdate == "some regdate"
      assert teacher.poscod == "some poscod"
      assert teacher.secondid == "some secondid"
      assert teacher.postitle == "some postitle"
      assert teacher.tscjob2 == "some tscjob2"
      assert teacher.bcenrlno == "some bcenrlno"
      assert teacher.job == "some job"
      assert teacher.tscjob3 == "some tscjob3"
      assert teacher.state == "some state"
      assert teacher.tscjob5 == "some tscjob5"
      assert teacher.tel == "some tel"
      assert teacher.addr1 == "some addr1"
      assert teacher.qdate == "some qdate"
      assert teacher.tchtype == "some tchtype"
      assert teacher.remark == "some remark"
      assert teacher.session == "some session"
      assert teacher.name == "some name"
      assert teacher.tscjob1 == "some tscjob1"
      assert teacher.nation == "some nation"
      assert teacher.addr3 == "some addr3"
      assert teacher.icno == "some icno"
      assert teacher.tscjob4 == "some tscjob4"
    end

    test "create_teacher/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher(@invalid_attrs)
    end

    test "update_teacher/2 with valid data updates the teacher" do
      teacher = teacher_fixture()
      assert {:ok, teacher} = Affairs.update_teacher(teacher, @update_attrs)
      assert %Teacher{} = teacher
      assert teacher.education == "some updated education"
      assert teacher.qrem == "some updated qrem"
      assert teacher.religion == "some updated religion"
      assert teacher.district == "some updated district"
      assert teacher.gid == "some updated gid"
      assert teacher.cname == "some updated cname"
      assert teacher.bdate == "some updated bdate"
      assert teacher.sex == "some updated sex"
      assert teacher.addr2 == "some updated addr2"
      assert teacher.race == "some updated race"
      assert teacher.tscjob6 == "some updated tscjob6"
      assert teacher.code == "some updated code"
      assert teacher.regdate == "some updated regdate"
      assert teacher.poscod == "some updated poscod"
      assert teacher.secondid == "some updated secondid"
      assert teacher.postitle == "some updated postitle"
      assert teacher.tscjob2 == "some updated tscjob2"
      assert teacher.bcenrlno == "some updated bcenrlno"
      assert teacher.job == "some updated job"
      assert teacher.tscjob3 == "some updated tscjob3"
      assert teacher.state == "some updated state"
      assert teacher.tscjob5 == "some updated tscjob5"
      assert teacher.tel == "some updated tel"
      assert teacher.addr1 == "some updated addr1"
      assert teacher.qdate == "some updated qdate"
      assert teacher.tchtype == "some updated tchtype"
      assert teacher.remark == "some updated remark"
      assert teacher.session == "some updated session"
      assert teacher.name == "some updated name"
      assert teacher.tscjob1 == "some updated tscjob1"
      assert teacher.nation == "some updated nation"
      assert teacher.addr3 == "some updated addr3"
      assert teacher.icno == "some updated icno"
      assert teacher.tscjob4 == "some updated tscjob4"
    end

    test "update_teacher/2 with invalid data returns error changeset" do
      teacher = teacher_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher(teacher, @invalid_attrs)
      assert teacher == Affairs.get_teacher!(teacher.id)
    end

    test "delete_teacher/1 deletes the teacher" do
      teacher = teacher_fixture()
      assert {:ok, %Teacher{}} = Affairs.delete_teacher(teacher)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher!(teacher.id) end
    end

    test "change_teacher/1 returns a teacher changeset" do
      teacher = teacher_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher(teacher)
    end
  end

  describe "teacher" do
    alias School.Affairs.Teacher

    @valid_attrs %{tscjob4: "some tscjob4", icno: "some icno", addr3: "some addr3", nation: "some nation", tscjob1: "some tscjob1", tccjob5: "some tccjob5", name: "some name", session: "some session", tccjob3: "some tccjob3", tccjob6: "some tccjob6", remark: "some remark", tchtype: "some tchtype", qdate: "some qdate", addr1: "some addr1", tel: "some tel", tscjob5: "some tscjob5", state: "some state", tscjob3: "some tscjob3", job: "some job", bcenrlno: "some bcenrlno", tscjob2: "some tscjob2", postitle: "some postitle", secondid: "some secondid", tccjob4: "some tccjob4", poscod: "some poscod", tccjob1: "some tccjob1", regdate: "some regdate", code: "some code", tscjob6: "some tscjob6", race: "some race", addr2: "some addr2", sex: "some sex", bdate: "some bdate", cname: "some cname", gid: "some gid", district: "some district", religion: "some religion", qrem: "some qrem", education: "some education"}
    @update_attrs %{tscjob4: "some updated tscjob4", icno: "some updated icno", addr3: "some updated addr3", nation: "some updated nation", tscjob1: "some updated tscjob1", tccjob5: "some updated tccjob5", name: "some updated name", session: "some updated session", tccjob3: "some updated tccjob3", tccjob6: "some updated tccjob6", remark: "some updated remark", tchtype: "some updated tchtype", qdate: "some updated qdate", addr1: "some updated addr1", tel: "some updated tel", tscjob5: "some updated tscjob5", state: "some updated state", tscjob3: "some updated tscjob3", job: "some updated job", bcenrlno: "some updated bcenrlno", tscjob2: "some updated tscjob2", postitle: "some updated postitle", secondid: "some updated secondid", tccjob4: "some updated tccjob4", poscod: "some updated poscod", tccjob1: "some updated tccjob1", regdate: "some updated regdate", code: "some updated code", tscjob6: "some updated tscjob6", race: "some updated race", addr2: "some updated addr2", sex: "some updated sex", bdate: "some updated bdate", cname: "some updated cname", gid: "some updated gid", district: "some updated district", religion: "some updated religion", qrem: "some updated qrem", education: "some updated education"}
    @invalid_attrs %{tscjob4: nil, icno: nil, addr3: nil, nation: nil, tscjob1: nil, tccjob5: nil, name: nil, session: nil, tccjob3: nil, tccjob6: nil, remark: nil, tchtype: nil, qdate: nil, addr1: nil, tel: nil, tscjob5: nil, state: nil, tscjob3: nil, job: nil, bcenrlno: nil, tscjob2: nil, postitle: nil, secondid: nil, tccjob4: nil, poscod: nil, tccjob1: nil, regdate: nil, code: nil, tscjob6: nil, race: nil, addr2: nil, sex: nil, bdate: nil, cname: nil, gid: nil, district: nil, religion: nil, qrem: nil, education: nil}

    def teacher_fixture(attrs \\ %{}) do
      {:ok, teacher} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher()

      teacher
    end

    test "list_teacher/0 returns all teacher" do
      teacher = teacher_fixture()
      assert Affairs.list_teacher() == [teacher]
    end

    test "get_teacher!/1 returns the teacher with given id" do
      teacher = teacher_fixture()
      assert Affairs.get_teacher!(teacher.id) == teacher
    end

    test "create_teacher/1 with valid data creates a teacher" do
      assert {:ok, %Teacher{} = teacher} = Affairs.create_teacher(@valid_attrs)
      assert teacher.education == "some education"
      assert teacher.qrem == "some qrem"
      assert teacher.religion == "some religion"
      assert teacher.district == "some district"
      assert teacher.gid == "some gid"
      assert teacher.cname == "some cname"
      assert teacher.bdate == "some bdate"
      assert teacher.sex == "some sex"
      assert teacher.addr2 == "some addr2"
      assert teacher.race == "some race"
      assert teacher.tscjob6 == "some tscjob6"
      assert teacher.code == "some code"
      assert teacher.regdate == "some regdate"
      assert teacher.tccjob1 == "some tccjob1"
      assert teacher.poscod == "some poscod"
      assert teacher.tccjob4 == "some tccjob4"
      assert teacher.secondid == "some secondid"
      assert teacher.postitle == "some postitle"
      assert teacher.tscjob2 == "some tscjob2"
      assert teacher.bcenrlno == "some bcenrlno"
      assert teacher.job == "some job"
      assert teacher.tscjob3 == "some tscjob3"
      assert teacher.state == "some state"
      assert teacher.tscjob5 == "some tscjob5"
      assert teacher.tel == "some tel"
      assert teacher.addr1 == "some addr1"
      assert teacher.qdate == "some qdate"
      assert teacher.tchtype == "some tchtype"
      assert teacher.remark == "some remark"
      assert teacher.tccjob6 == "some tccjob6"
      assert teacher.tccjob3 == "some tccjob3"
      assert teacher.session == "some session"
      assert teacher.name == "some name"
      assert teacher.tccjob5 == "some tccjob5"
      assert teacher.tscjob1 == "some tscjob1"
      assert teacher.nation == "some nation"
      assert teacher.addr3 == "some addr3"
      assert teacher.icno == "some icno"
      assert teacher.tscjob4 == "some tscjob4"
    end

    test "create_teacher/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher(@invalid_attrs)
    end

    test "update_teacher/2 with valid data updates the teacher" do
      teacher = teacher_fixture()
      assert {:ok, teacher} = Affairs.update_teacher(teacher, @update_attrs)
      assert %Teacher{} = teacher
      assert teacher.education == "some updated education"
      assert teacher.qrem == "some updated qrem"
      assert teacher.religion == "some updated religion"
      assert teacher.district == "some updated district"
      assert teacher.gid == "some updated gid"
      assert teacher.cname == "some updated cname"
      assert teacher.bdate == "some updated bdate"
      assert teacher.sex == "some updated sex"
      assert teacher.addr2 == "some updated addr2"
      assert teacher.race == "some updated race"
      assert teacher.tscjob6 == "some updated tscjob6"
      assert teacher.code == "some updated code"
      assert teacher.regdate == "some updated regdate"
      assert teacher.tccjob1 == "some updated tccjob1"
      assert teacher.poscod == "some updated poscod"
      assert teacher.tccjob4 == "some updated tccjob4"
      assert teacher.secondid == "some updated secondid"
      assert teacher.postitle == "some updated postitle"
      assert teacher.tscjob2 == "some updated tscjob2"
      assert teacher.bcenrlno == "some updated bcenrlno"
      assert teacher.job == "some updated job"
      assert teacher.tscjob3 == "some updated tscjob3"
      assert teacher.state == "some updated state"
      assert teacher.tscjob5 == "some updated tscjob5"
      assert teacher.tel == "some updated tel"
      assert teacher.addr1 == "some updated addr1"
      assert teacher.qdate == "some updated qdate"
      assert teacher.tchtype == "some updated tchtype"
      assert teacher.remark == "some updated remark"
      assert teacher.tccjob6 == "some updated tccjob6"
      assert teacher.tccjob3 == "some updated tccjob3"
      assert teacher.session == "some updated session"
      assert teacher.name == "some updated name"
      assert teacher.tccjob5 == "some updated tccjob5"
      assert teacher.tscjob1 == "some updated tscjob1"
      assert teacher.nation == "some updated nation"
      assert teacher.addr3 == "some updated addr3"
      assert teacher.icno == "some updated icno"
      assert teacher.tscjob4 == "some updated tscjob4"
    end

    test "update_teacher/2 with invalid data returns error changeset" do
      teacher = teacher_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher(teacher, @invalid_attrs)
      assert teacher == Affairs.get_teacher!(teacher.id)
    end

    test "delete_teacher/1 deletes the teacher" do
      teacher = teacher_fixture()
      assert {:ok, %Teacher{}} = Affairs.delete_teacher(teacher)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher!(teacher.id) end
    end

    test "change_teacher/1 returns a teacher changeset" do
      teacher = teacher_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher(teacher)
    end
  end

  describe "teacher" do
    alias School.Affairs.Teacher

    @valid_attrs %{tccjob6: "some tccjob6", tscjob4: "some tscjob4", icno: "some icno", addr3: "some addr3", nation: "some nation", tscjob1: "some tscjob1", tccjob4: "some tccjob4", name: "some name", session: "some session", tccjob2: "some tccjob2", tccjob5: "some tccjob5", remark: "some remark", tchtype: "some tchtype", qdate: "some qdate", addr1: "some addr1", tel: "some tel", tscjob5: "some tscjob5", state: "some state", tscjob3: "some tscjob3", job: "some job", bcenrlno: "some bcenrlno", tscjob2: "some tscjob2", postitle: "some postitle", secondid: "some secondid", tccjob3: "some tccjob3", poscod: "some poscod", tccjob1: "some tccjob1", regdate: "some regdate", code: "some code", tscjob6: "some tscjob6", race: "some race", addr2: "some addr2", sex: "some sex", bdate: "some bdate", cname: "some cname", gid: "some gid", district: "some district", religion: "some religion", qrem: "some qrem", education: "some education"}
    @update_attrs %{tccjob6: "some updated tccjob6", tscjob4: "some updated tscjob4", icno: "some updated icno", addr3: "some updated addr3", nation: "some updated nation", tscjob1: "some updated tscjob1", tccjob4: "some updated tccjob4", name: "some updated name", session: "some updated session", tccjob2: "some updated tccjob2", tccjob5: "some updated tccjob5", remark: "some updated remark", tchtype: "some updated tchtype", qdate: "some updated qdate", addr1: "some updated addr1", tel: "some updated tel", tscjob5: "some updated tscjob5", state: "some updated state", tscjob3: "some updated tscjob3", job: "some updated job", bcenrlno: "some updated bcenrlno", tscjob2: "some updated tscjob2", postitle: "some updated postitle", secondid: "some updated secondid", tccjob3: "some updated tccjob3", poscod: "some updated poscod", tccjob1: "some updated tccjob1", regdate: "some updated regdate", code: "some updated code", tscjob6: "some updated tscjob6", race: "some updated race", addr2: "some updated addr2", sex: "some updated sex", bdate: "some updated bdate", cname: "some updated cname", gid: "some updated gid", district: "some updated district", religion: "some updated religion", qrem: "some updated qrem", education: "some updated education"}
    @invalid_attrs %{tccjob6: nil, tscjob4: nil, icno: nil, addr3: nil, nation: nil, tscjob1: nil, tccjob4: nil, name: nil, session: nil, tccjob2: nil, tccjob5: nil, remark: nil, tchtype: nil, qdate: nil, addr1: nil, tel: nil, tscjob5: nil, state: nil, tscjob3: nil, job: nil, bcenrlno: nil, tscjob2: nil, postitle: nil, secondid: nil, tccjob3: nil, poscod: nil, tccjob1: nil, regdate: nil, code: nil, tscjob6: nil, race: nil, addr2: nil, sex: nil, bdate: nil, cname: nil, gid: nil, district: nil, religion: nil, qrem: nil, education: nil}

    def teacher_fixture(attrs \\ %{}) do
      {:ok, teacher} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher()

      teacher
    end

    test "list_teacher/0 returns all teacher" do
      teacher = teacher_fixture()
      assert Affairs.list_teacher() == [teacher]
    end

    test "get_teacher!/1 returns the teacher with given id" do
      teacher = teacher_fixture()
      assert Affairs.get_teacher!(teacher.id) == teacher
    end

    test "create_teacher/1 with valid data creates a teacher" do
      assert {:ok, %Teacher{} = teacher} = Affairs.create_teacher(@valid_attrs)
      assert teacher.education == "some education"
      assert teacher.qrem == "some qrem"
      assert teacher.religion == "some religion"
      assert teacher.district == "some district"
      assert teacher.gid == "some gid"
      assert teacher.cname == "some cname"
      assert teacher.bdate == "some bdate"
      assert teacher.sex == "some sex"
      assert teacher.addr2 == "some addr2"
      assert teacher.race == "some race"
      assert teacher.tscjob6 == "some tscjob6"
      assert teacher.code == "some code"
      assert teacher.regdate == "some regdate"
      assert teacher.tccjob1 == "some tccjob1"
      assert teacher.poscod == "some poscod"
      assert teacher.tccjob3 == "some tccjob3"
      assert teacher.secondid == "some secondid"
      assert teacher.postitle == "some postitle"
      assert teacher.tscjob2 == "some tscjob2"
      assert teacher.bcenrlno == "some bcenrlno"
      assert teacher.job == "some job"
      assert teacher.tscjob3 == "some tscjob3"
      assert teacher.state == "some state"
      assert teacher.tscjob5 == "some tscjob5"
      assert teacher.tel == "some tel"
      assert teacher.addr1 == "some addr1"
      assert teacher.qdate == "some qdate"
      assert teacher.tchtype == "some tchtype"
      assert teacher.remark == "some remark"
      assert teacher.tccjob5 == "some tccjob5"
      assert teacher.tccjob2 == "some tccjob2"
      assert teacher.session == "some session"
      assert teacher.name == "some name"
      assert teacher.tccjob4 == "some tccjob4"
      assert teacher.tscjob1 == "some tscjob1"
      assert teacher.nation == "some nation"
      assert teacher.addr3 == "some addr3"
      assert teacher.icno == "some icno"
      assert teacher.tscjob4 == "some tscjob4"
      assert teacher.tccjob6 == "some tccjob6"
    end

    test "create_teacher/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher(@invalid_attrs)
    end

    test "update_teacher/2 with valid data updates the teacher" do
      teacher = teacher_fixture()
      assert {:ok, teacher} = Affairs.update_teacher(teacher, @update_attrs)
      assert %Teacher{} = teacher
      assert teacher.education == "some updated education"
      assert teacher.qrem == "some updated qrem"
      assert teacher.religion == "some updated religion"
      assert teacher.district == "some updated district"
      assert teacher.gid == "some updated gid"
      assert teacher.cname == "some updated cname"
      assert teacher.bdate == "some updated bdate"
      assert teacher.sex == "some updated sex"
      assert teacher.addr2 == "some updated addr2"
      assert teacher.race == "some updated race"
      assert teacher.tscjob6 == "some updated tscjob6"
      assert teacher.code == "some updated code"
      assert teacher.regdate == "some updated regdate"
      assert teacher.tccjob1 == "some updated tccjob1"
      assert teacher.poscod == "some updated poscod"
      assert teacher.tccjob3 == "some updated tccjob3"
      assert teacher.secondid == "some updated secondid"
      assert teacher.postitle == "some updated postitle"
      assert teacher.tscjob2 == "some updated tscjob2"
      assert teacher.bcenrlno == "some updated bcenrlno"
      assert teacher.job == "some updated job"
      assert teacher.tscjob3 == "some updated tscjob3"
      assert teacher.state == "some updated state"
      assert teacher.tscjob5 == "some updated tscjob5"
      assert teacher.tel == "some updated tel"
      assert teacher.addr1 == "some updated addr1"
      assert teacher.qdate == "some updated qdate"
      assert teacher.tchtype == "some updated tchtype"
      assert teacher.remark == "some updated remark"
      assert teacher.tccjob5 == "some updated tccjob5"
      assert teacher.tccjob2 == "some updated tccjob2"
      assert teacher.session == "some updated session"
      assert teacher.name == "some updated name"
      assert teacher.tccjob4 == "some updated tccjob4"
      assert teacher.tscjob1 == "some updated tscjob1"
      assert teacher.nation == "some updated nation"
      assert teacher.addr3 == "some updated addr3"
      assert teacher.icno == "some updated icno"
      assert teacher.tscjob4 == "some updated tscjob4"
      assert teacher.tccjob6 == "some updated tccjob6"
    end

    test "update_teacher/2 with invalid data returns error changeset" do
      teacher = teacher_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher(teacher, @invalid_attrs)
      assert teacher == Affairs.get_teacher!(teacher.id)
    end

    test "delete_teacher/1 deletes the teacher" do
      teacher = teacher_fixture()
      assert {:ok, %Teacher{}} = Affairs.delete_teacher(teacher)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher!(teacher.id) end
    end

    test "change_teacher/1 returns a teacher changeset" do
      teacher = teacher_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher(teacher)
    end
  end

  describe "subjects" do
    alias School.Affairs.Subject

    @valid_attrs %{cdesc: "some cdesc", code: "some code", description: "some description", sysdef: 42}
    @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description", sysdef: 43}
    @invalid_attrs %{cdesc: nil, code: nil, description: nil, sysdef: nil}

    def subject_fixture(attrs \\ %{}) do
      {:ok, subject} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_subject()

      subject
    end

    test "list_subjects/0 returns all subjects" do
      subject = subject_fixture()
      assert Affairs.list_subjects() == [subject]
    end

    test "get_subject!/1 returns the subject with given id" do
      subject = subject_fixture()
      assert Affairs.get_subject!(subject.id) == subject
    end

    test "create_subject/1 with valid data creates a subject" do
      assert {:ok, %Subject{} = subject} = Affairs.create_subject(@valid_attrs)
      assert subject.cdesc == "some cdesc"
      assert subject.code == "some code"
      assert subject.description == "some description"
      assert subject.sysdef == 42
    end

    test "create_subject/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_subject(@invalid_attrs)
    end

    test "update_subject/2 with valid data updates the subject" do
      subject = subject_fixture()
      assert {:ok, subject} = Affairs.update_subject(subject, @update_attrs)
      assert %Subject{} = subject
      assert subject.cdesc == "some updated cdesc"
      assert subject.code == "some updated code"
      assert subject.description == "some updated description"
      assert subject.sysdef == 43
    end

    test "update_subject/2 with invalid data returns error changeset" do
      subject = subject_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_subject(subject, @invalid_attrs)
      assert subject == Affairs.get_subject!(subject.id)
    end

    test "delete_subject/1 deletes the subject" do
      subject = subject_fixture()
      assert {:ok, %Subject{}} = Affairs.delete_subject(subject)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_subject!(subject.id) end
    end

    test "change_subject/1 returns a subject changeset" do
      subject = subject_fixture()
      assert %Ecto.Changeset{} = Affairs.change_subject(subject)
    end
  end

  describe "subject" do
    alias School.Affairs.Subject

    @valid_attrs %{cdesc: "some cdesc", code: "some code", description: "some description", sysdef: 42}
    @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description", sysdef: 43}
    @invalid_attrs %{cdesc: nil, code: nil, description: nil, sysdef: nil}

    def subject_fixture(attrs \\ %{}) do
      {:ok, subject} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_subject()

      subject
    end

    test "list_subject/0 returns all subject" do
      subject = subject_fixture()
      assert Affairs.list_subject() == [subject]
    end

    test "get_subject!/1 returns the subject with given id" do
      subject = subject_fixture()
      assert Affairs.get_subject!(subject.id) == subject
    end

    test "create_subject/1 with valid data creates a subject" do
      assert {:ok, %Subject{} = subject} = Affairs.create_subject(@valid_attrs)
      assert subject.cdesc == "some cdesc"
      assert subject.code == "some code"
      assert subject.description == "some description"
      assert subject.sysdef == 42
    end

    test "create_subject/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_subject(@invalid_attrs)
    end

    test "update_subject/2 with valid data updates the subject" do
      subject = subject_fixture()
      assert {:ok, subject} = Affairs.update_subject(subject, @update_attrs)
      assert %Subject{} = subject
      assert subject.cdesc == "some updated cdesc"
      assert subject.code == "some updated code"
      assert subject.description == "some updated description"
      assert subject.sysdef == 43
    end

    test "update_subject/2 with invalid data returns error changeset" do
      subject = subject_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_subject(subject, @invalid_attrs)
      assert subject == Affairs.get_subject!(subject.id)
    end

    test "delete_subject/1 deletes the subject" do
      subject = subject_fixture()
      assert {:ok, %Subject{}} = Affairs.delete_subject(subject)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_subject!(subject.id) end
    end

    test "change_subject/1 returns a subject changeset" do
      subject = subject_fixture()
      assert %Ecto.Changeset{} = Affairs.change_subject(subject)
    end
  end

  describe "parent" do
    alias School.Affairs.Parent

    @valid_attrs %{addr1: "some addr1", addr2: "some addr2", addr3: "some addr3", cname: "some cname", country: "some country", district: "some district", epaddr1: "some epaddr1", epaddr2: "some epaddr2", epaddr3: "some epaddr3", epdistrict: "some epdistrict", epname: "some epname", epposcod: "some epposcod", epstate: "some epstate", hphone: "some hphone", htel: "some htel", icno: "some icno", income: "some income", inctaxno: "some inctaxno", nacert: "some nacert", name: "some name", nation: "some nation", occup: "some occup", oldic: "some oldic", otel: "some otel", poscod: "some poscod", pstatus: "some pstatus", race: "some race", refno: "some refno", relation: "some relation", religion: "some religion", state: "some state", tanggn: "some tanggn"}
    @update_attrs %{addr1: "some updated addr1", addr2: "some updated addr2", addr3: "some updated addr3", cname: "some updated cname", country: "some updated country", district: "some updated district", epaddr1: "some updated epaddr1", epaddr2: "some updated epaddr2", epaddr3: "some updated epaddr3", epdistrict: "some updated epdistrict", epname: "some updated epname", epposcod: "some updated epposcod", epstate: "some updated epstate", hphone: "some updated hphone", htel: "some updated htel", icno: "some updated icno", income: "some updated income", inctaxno: "some updated inctaxno", nacert: "some updated nacert", name: "some updated name", nation: "some updated nation", occup: "some updated occup", oldic: "some updated oldic", otel: "some updated otel", poscod: "some updated poscod", pstatus: "some updated pstatus", race: "some updated race", refno: "some updated refno", relation: "some updated relation", religion: "some updated religion", state: "some updated state", tanggn: "some updated tanggn"}
    @invalid_attrs %{addr1: nil, addr2: nil, addr3: nil, cname: nil, country: nil, district: nil, epaddr1: nil, epaddr2: nil, epaddr3: nil, epdistrict: nil, epname: nil, epposcod: nil, epstate: nil, hphone: nil, htel: nil, icno: nil, income: nil, inctaxno: nil, nacert: nil, name: nil, nation: nil, occup: nil, oldic: nil, otel: nil, poscod: nil, pstatus: nil, race: nil, refno: nil, relation: nil, religion: nil, state: nil, tanggn: nil}

    def parent_fixture(attrs \\ %{}) do
      {:ok, parent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_parent()

      parent
    end

    test "list_parent/0 returns all parent" do
      parent = parent_fixture()
      assert Affairs.list_parent() == [parent]
    end

    test "get_parent!/1 returns the parent with given id" do
      parent = parent_fixture()
      assert Affairs.get_parent!(parent.id) == parent
    end

    test "create_parent/1 with valid data creates a parent" do
      assert {:ok, %Parent{} = parent} = Affairs.create_parent(@valid_attrs)
      assert parent.addr1 == "some addr1"
      assert parent.addr2 == "some addr2"
      assert parent.addr3 == "some addr3"
      assert parent.cname == "some cname"
      assert parent.country == "some country"
      assert parent.district == "some district"
      assert parent.epaddr1 == "some epaddr1"
      assert parent.epaddr2 == "some epaddr2"
      assert parent.epaddr3 == "some epaddr3"
      assert parent.epdistrict == "some epdistrict"
      assert parent.epname == "some epname"
      assert parent.epposcod == "some epposcod"
      assert parent.epstate == "some epstate"
      assert parent.hphone == "some hphone"
      assert parent.htel == "some htel"
      assert parent.icno == "some icno"
      assert parent.income == "some income"
      assert parent.inctaxno == "some inctaxno"
      assert parent.nacert == "some nacert"
      assert parent.name == "some name"
      assert parent.nation == "some nation"
      assert parent.occup == "some occup"
      assert parent.oldic == "some oldic"
      assert parent.otel == "some otel"
      assert parent.poscod == "some poscod"
      assert parent.pstatus == "some pstatus"
      assert parent.race == "some race"
      assert parent.refno == "some refno"
      assert parent.relation == "some relation"
      assert parent.religion == "some religion"
      assert parent.state == "some state"
      assert parent.tanggn == "some tanggn"
    end

    test "create_parent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_parent(@invalid_attrs)
    end

    test "update_parent/2 with valid data updates the parent" do
      parent = parent_fixture()
      assert {:ok, parent} = Affairs.update_parent(parent, @update_attrs)
      assert %Parent{} = parent
      assert parent.addr1 == "some updated addr1"
      assert parent.addr2 == "some updated addr2"
      assert parent.addr3 == "some updated addr3"
      assert parent.cname == "some updated cname"
      assert parent.country == "some updated country"
      assert parent.district == "some updated district"
      assert parent.epaddr1 == "some updated epaddr1"
      assert parent.epaddr2 == "some updated epaddr2"
      assert parent.epaddr3 == "some updated epaddr3"
      assert parent.epdistrict == "some updated epdistrict"
      assert parent.epname == "some updated epname"
      assert parent.epposcod == "some updated epposcod"
      assert parent.epstate == "some updated epstate"
      assert parent.hphone == "some updated hphone"
      assert parent.htel == "some updated htel"
      assert parent.icno == "some updated icno"
      assert parent.income == "some updated income"
      assert parent.inctaxno == "some updated inctaxno"
      assert parent.nacert == "some updated nacert"
      assert parent.name == "some updated name"
      assert parent.nation == "some updated nation"
      assert parent.occup == "some updated occup"
      assert parent.oldic == "some updated oldic"
      assert parent.otel == "some updated otel"
      assert parent.poscod == "some updated poscod"
      assert parent.pstatus == "some updated pstatus"
      assert parent.race == "some updated race"
      assert parent.refno == "some updated refno"
      assert parent.relation == "some updated relation"
      assert parent.religion == "some updated religion"
      assert parent.state == "some updated state"
      assert parent.tanggn == "some updated tanggn"
    end

    test "update_parent/2 with invalid data returns error changeset" do
      parent = parent_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_parent(parent, @invalid_attrs)
      assert parent == Affairs.get_parent!(parent.id)
    end

    test "delete_parent/1 deletes the parent" do
      parent = parent_fixture()
      assert {:ok, %Parent{}} = Affairs.delete_parent(parent)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_parent!(parent.id) end
    end

    test "change_parent/1 returns a parent changeset" do
      parent = parent_fixture()
      assert %Ecto.Changeset{} = Affairs.change_parent(parent)
    end
  end

  describe "timetable" do
    alias School.Affairs.Timetable

    @valid_attrs %{class_id: 42, institution_id: 42, level_id: 42, period_id: 42, semester_id: 42}
    @update_attrs %{class_id: 43, institution_id: 43, level_id: 43, period_id: 43, semester_id: 43}
    @invalid_attrs %{class_id: nil, institution_id: nil, level_id: nil, period_id: nil, semester_id: nil}

    def timetable_fixture(attrs \\ %{}) do
      {:ok, timetable} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_timetable()

      timetable
    end

    test "list_timetable/0 returns all timetable" do
      timetable = timetable_fixture()
      assert Affairs.list_timetable() == [timetable]
    end

    test "get_timetable!/1 returns the timetable with given id" do
      timetable = timetable_fixture()
      assert Affairs.get_timetable!(timetable.id) == timetable
    end

    test "create_timetable/1 with valid data creates a timetable" do
      assert {:ok, %Timetable{} = timetable} = Affairs.create_timetable(@valid_attrs)
      assert timetable.class_id == 42
      assert timetable.institution_id == 42
      assert timetable.level_id == 42
      assert timetable.period_id == 42
      assert timetable.semester_id == 42
    end

    test "create_timetable/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_timetable(@invalid_attrs)
    end

    test "update_timetable/2 with valid data updates the timetable" do
      timetable = timetable_fixture()
      assert {:ok, timetable} = Affairs.update_timetable(timetable, @update_attrs)
      assert %Timetable{} = timetable
      assert timetable.class_id == 43
      assert timetable.institution_id == 43
      assert timetable.level_id == 43
      assert timetable.period_id == 43
      assert timetable.semester_id == 43
    end

    test "update_timetable/2 with invalid data returns error changeset" do
      timetable = timetable_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_timetable(timetable, @invalid_attrs)
      assert timetable == Affairs.get_timetable!(timetable.id)
    end

    test "delete_timetable/1 deletes the timetable" do
      timetable = timetable_fixture()
      assert {:ok, %Timetable{}} = Affairs.delete_timetable(timetable)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_timetable!(timetable.id) end
    end

    test "change_timetable/1 returns a timetable changeset" do
      timetable = timetable_fixture()
      assert %Ecto.Changeset{} = Affairs.change_timetable(timetable)
    end
  end

  describe "period" do
    alias School.Affairs.Period

    @valid_attrs %{day: "some day", end_time: ~T[14:00:00.000000], start_time: ~T[14:00:00.000000], subject_id: 42, teacher_id: 42}
    @update_attrs %{day: "some updated day", end_time: ~T[15:01:01.000000], start_time: ~T[15:01:01.000000], subject_id: 43, teacher_id: 43}
    @invalid_attrs %{day: nil, end_time: nil, start_time: nil, subject_id: nil, teacher_id: nil}

    def period_fixture(attrs \\ %{}) do
      {:ok, period} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_period()

      period
    end

    test "list_period/0 returns all period" do
      period = period_fixture()
      assert Affairs.list_period() == [period]
    end

    test "get_period!/1 returns the period with given id" do
      period = period_fixture()
      assert Affairs.get_period!(period.id) == period
    end

    test "create_period/1 with valid data creates a period" do
      assert {:ok, %Period{} = period} = Affairs.create_period(@valid_attrs)
      assert period.day == "some day"
      assert period.end_time == ~T[14:00:00.000000]
      assert period.start_time == ~T[14:00:00.000000]
      assert period.subject_id == 42
      assert period.teacher_id == 42
    end

    test "create_period/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_period(@invalid_attrs)
    end

    test "update_period/2 with valid data updates the period" do
      period = period_fixture()
      assert {:ok, period} = Affairs.update_period(period, @update_attrs)
      assert %Period{} = period
      assert period.day == "some updated day"
      assert period.end_time == ~T[15:01:01.000000]
      assert period.start_time == ~T[15:01:01.000000]
      assert period.subject_id == 43
      assert period.teacher_id == 43
    end

    test "update_period/2 with invalid data returns error changeset" do
      period = period_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_period(period, @invalid_attrs)
      assert period == Affairs.get_period!(period.id)
    end

    test "delete_period/1 deletes the period" do
      period = period_fixture()
      assert {:ok, %Period{}} = Affairs.delete_period(period)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_period!(period.id) end
    end

    test "change_period/1 returns a period changeset" do
      period = period_fixture()
      assert %Ecto.Changeset{} = Affairs.change_period(period)
    end
  end

  describe "day" do
    alias School.Affairs.Day

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def day_fixture(attrs \\ %{}) do
      {:ok, day} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_day()

      day
    end

    test "list_day/0 returns all day" do
      day = day_fixture()
      assert Affairs.list_day() == [day]
    end

    test "get_day!/1 returns the day with given id" do
      day = day_fixture()
      assert Affairs.get_day!(day.id) == day
    end

    test "create_day/1 with valid data creates a day" do
      assert {:ok, %Day{} = day} = Affairs.create_day(@valid_attrs)
      assert day.name == "some name"
    end

    test "create_day/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_day(@invalid_attrs)
    end

    test "update_day/2 with valid data updates the day" do
      day = day_fixture()
      assert {:ok, day} = Affairs.update_day(day, @update_attrs)
      assert %Day{} = day
      assert day.name == "some updated name"
    end

    test "update_day/2 with invalid data returns error changeset" do
      day = day_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_day(day, @invalid_attrs)
      assert day == Affairs.get_day!(day.id)
    end

    test "delete_day/1 deletes the day" do
      day = day_fixture()
      assert {:ok, %Day{}} = Affairs.delete_day(day)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_day!(day.id) end
    end

    test "change_day/1 returns a day changeset" do
      day = day_fixture()
      assert %Ecto.Changeset{} = Affairs.change_day(day)
    end
  end

  describe "grade" do
    alias School.Affairs.Grade

    @valid_attrs %{max: 42, mix: 42, name: "some name"}
    @update_attrs %{max: 43, mix: 43, name: "some updated name"}
    @invalid_attrs %{max: nil, mix: nil, name: nil}

    def grade_fixture(attrs \\ %{}) do
      {:ok, grade} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_grade()

      grade
    end

    test "list_grade/0 returns all grade" do
      grade = grade_fixture()
      assert Affairs.list_grade() == [grade]
    end

    test "get_grade!/1 returns the grade with given id" do
      grade = grade_fixture()
      assert Affairs.get_grade!(grade.id) == grade
    end

    test "create_grade/1 with valid data creates a grade" do
      assert {:ok, %Grade{} = grade} = Affairs.create_grade(@valid_attrs)
      assert grade.max == 42
      assert grade.mix == 42
      assert grade.name == "some name"
    end

    test "create_grade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_grade(@invalid_attrs)
    end

    test "update_grade/2 with valid data updates the grade" do
      grade = grade_fixture()
      assert {:ok, grade} = Affairs.update_grade(grade, @update_attrs)
      assert %Grade{} = grade
      assert grade.max == 43
      assert grade.mix == 43
      assert grade.name == "some updated name"
    end

    test "update_grade/2 with invalid data returns error changeset" do
      grade = grade_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_grade(grade, @invalid_attrs)
      assert grade == Affairs.get_grade!(grade.id)
    end

    test "delete_grade/1 deletes the grade" do
      grade = grade_fixture()
      assert {:ok, %Grade{}} = Affairs.delete_grade(grade)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_grade!(grade.id) end
    end

    test "change_grade/1 returns a grade changeset" do
      grade = grade_fixture()
      assert %Ecto.Changeset{} = Affairs.change_grade(grade)
    end
  end

  describe "name" do
    alias School.Affairs.ExamMaster

    @valid_attrs %{exam_id: 42, level_id: 42, semester_id: 42, year: "some year"}
    @update_attrs %{exam_id: 43, level_id: 43, semester_id: 43, year: "some updated year"}
    @invalid_attrs %{exam_id: nil, level_id: nil, semester_id: nil, year: nil}

    def exam_master_fixture(attrs \\ %{}) do
      {:ok, exam_master} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_exam_master()

      exam_master
    end

    test "list_name/0 returns all name" do
      exam_master = exam_master_fixture()
      assert Affairs.list_name() == [exam_master]
    end

    test "get_exam_master!/1 returns the exam_master with given id" do
      exam_master = exam_master_fixture()
      assert Affairs.get_exam_master!(exam_master.id) == exam_master
    end

    test "create_exam_master/1 with valid data creates a exam_master" do
      assert {:ok, %ExamMaster{} = exam_master} = Affairs.create_exam_master(@valid_attrs)
      assert exam_master.exam_id == 42
      assert exam_master.level_id == 42
      assert exam_master.semester_id == 42
      assert exam_master.year == "some year"
    end

    test "create_exam_master/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_exam_master(@invalid_attrs)
    end

    test "update_exam_master/2 with valid data updates the exam_master" do
      exam_master = exam_master_fixture()
      assert {:ok, exam_master} = Affairs.update_exam_master(exam_master, @update_attrs)
      assert %ExamMaster{} = exam_master
      assert exam_master.exam_id == 43
      assert exam_master.level_id == 43
      assert exam_master.semester_id == 43
      assert exam_master.year == "some updated year"
    end

    test "update_exam_master/2 with invalid data returns error changeset" do
      exam_master = exam_master_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_exam_master(exam_master, @invalid_attrs)
      assert exam_master == Affairs.get_exam_master!(exam_master.id)
    end

    test "delete_exam_master/1 deletes the exam_master" do
      exam_master = exam_master_fixture()
      assert {:ok, %ExamMaster{}} = Affairs.delete_exam_master(exam_master)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_exam_master!(exam_master.id) end
    end

    test "change_exam_master/1 returns a exam_master changeset" do
      exam_master = exam_master_fixture()
      assert %Ecto.Changeset{} = Affairs.change_exam_master(exam_master)
    end
  end

  describe "exam" do
    alias School.Affairs.Exam

    @valid_attrs %{exam_master_id: 42, subject_id: 42}
    @update_attrs %{exam_master_id: 43, subject_id: 43}
    @invalid_attrs %{exam_master_id: nil, subject_id: nil}

    def exam_fixture(attrs \\ %{}) do
      {:ok, exam} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_exam()

      exam
    end

    test "list_exam/0 returns all exam" do
      exam = exam_fixture()
      assert Affairs.list_exam() == [exam]
    end

    test "get_exam!/1 returns the exam with given id" do
      exam = exam_fixture()
      assert Affairs.get_exam!(exam.id) == exam
    end

    test "create_exam/1 with valid data creates a exam" do
      assert {:ok, %Exam{} = exam} = Affairs.create_exam(@valid_attrs)
      assert exam.exam_master_id == 42
      assert exam.subject_id == 42
    end

    test "create_exam/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_exam(@invalid_attrs)
    end

    test "update_exam/2 with valid data updates the exam" do
      exam = exam_fixture()
      assert {:ok, exam} = Affairs.update_exam(exam, @update_attrs)
      assert %Exam{} = exam
      assert exam.exam_master_id == 43
      assert exam.subject_id == 43
    end

    test "update_exam/2 with invalid data returns error changeset" do
      exam = exam_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_exam(exam, @invalid_attrs)
      assert exam == Affairs.get_exam!(exam.id)
    end

    test "delete_exam/1 deletes the exam" do
      exam = exam_fixture()
      assert {:ok, %Exam{}} = Affairs.delete_exam(exam)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_exam!(exam.id) end
    end

    test "change_exam/1 returns a exam changeset" do
      exam = exam_fixture()
      assert %Ecto.Changeset{} = Affairs.change_exam(exam)
    end
  end

  describe "exam_master" do
    alias School.Affairs.ExamMaster

    @valid_attrs %{level_id: 42, name: "some name", semester_id: 42, year: "some year"}
    @update_attrs %{level_id: 43, name: "some updated name", semester_id: 43, year: "some updated year"}
    @invalid_attrs %{level_id: nil, name: nil, semester_id: nil, year: nil}

    def exam_master_fixture(attrs \\ %{}) do
      {:ok, exam_master} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_exam_master()

      exam_master
    end

    test "list_exam_master/0 returns all exam_master" do
      exam_master = exam_master_fixture()
      assert Affairs.list_exam_master() == [exam_master]
    end

    test "get_exam_master!/1 returns the exam_master with given id" do
      exam_master = exam_master_fixture()
      assert Affairs.get_exam_master!(exam_master.id) == exam_master
    end

    test "create_exam_master/1 with valid data creates a exam_master" do
      assert {:ok, %ExamMaster{} = exam_master} = Affairs.create_exam_master(@valid_attrs)
      assert exam_master.level_id == 42
      assert exam_master.name == "some name"
      assert exam_master.semester_id == 42
      assert exam_master.year == "some year"
    end

    test "create_exam_master/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_exam_master(@invalid_attrs)
    end

    test "update_exam_master/2 with valid data updates the exam_master" do
      exam_master = exam_master_fixture()
      assert {:ok, exam_master} = Affairs.update_exam_master(exam_master, @update_attrs)
      assert %ExamMaster{} = exam_master
      assert exam_master.level_id == 43
      assert exam_master.name == "some updated name"
      assert exam_master.semester_id == 43
      assert exam_master.year == "some updated year"
    end

    test "update_exam_master/2 with invalid data returns error changeset" do
      exam_master = exam_master_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_exam_master(exam_master, @invalid_attrs)
      assert exam_master == Affairs.get_exam_master!(exam_master.id)
    end

    test "delete_exam_master/1 deletes the exam_master" do
      exam_master = exam_master_fixture()
      assert {:ok, %ExamMaster{}} = Affairs.delete_exam_master(exam_master)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_exam_master!(exam_master.id) end
    end

    test "change_exam_master/1 returns a exam_master changeset" do
      exam_master = exam_master_fixture()
      assert %Ecto.Changeset{} = Affairs.change_exam_master(exam_master)
    end
  end

  describe "exam_mark" do
    alias School.Affairs.ExamMar

    @valid_attrs %{class_id: 42, exam_id: 42, mark: 42, student_id: 42, subject_id: 42}
    @update_attrs %{class_id: 43, exam_id: 43, mark: 43, student_id: 43, subject_id: 43}
    @invalid_attrs %{class_id: nil, exam_id: nil, mark: nil, student_id: nil, subject_id: nil}

    def exam_mar_fixture(attrs \\ %{}) do
      {:ok, exam_mar} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_exam_mar()

      exam_mar
    end

    test "list_exam_mark/0 returns all exam_mark" do
      exam_mar = exam_mar_fixture()
      assert Affairs.list_exam_mark() == [exam_mar]
    end

    test "get_exam_mar!/1 returns the exam_mar with given id" do
      exam_mar = exam_mar_fixture()
      assert Affairs.get_exam_mar!(exam_mar.id) == exam_mar
    end

    test "create_exam_mar/1 with valid data creates a exam_mar" do
      assert {:ok, %ExamMar{} = exam_mar} = Affairs.create_exam_mar(@valid_attrs)
      assert exam_mar.class_id == 42
      assert exam_mar.exam_id == 42
      assert exam_mar.mark == 42
      assert exam_mar.student_id == 42
      assert exam_mar.subject_id == 42
    end

    test "create_exam_mar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_exam_mar(@invalid_attrs)
    end

    test "update_exam_mar/2 with valid data updates the exam_mar" do
      exam_mar = exam_mar_fixture()
      assert {:ok, exam_mar} = Affairs.update_exam_mar(exam_mar, @update_attrs)
      assert %ExamMar{} = exam_mar
      assert exam_mar.class_id == 43
      assert exam_mar.exam_id == 43
      assert exam_mar.mark == 43
      assert exam_mar.student_id == 43
      assert exam_mar.subject_id == 43
    end

    test "update_exam_mar/2 with invalid data returns error changeset" do
      exam_mar = exam_mar_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_exam_mar(exam_mar, @invalid_attrs)
      assert exam_mar == Affairs.get_exam_mar!(exam_mar.id)
    end

    test "delete_exam_mar/1 deletes the exam_mar" do
      exam_mar = exam_mar_fixture()
      assert {:ok, %ExamMar{}} = Affairs.delete_exam_mar(exam_mar)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_exam_mar!(exam_mar.id) end
    end

    test "change_exam_mar/1 returns a exam_mar changeset" do
      exam_mar = exam_mar_fixture()
      assert %Ecto.Changeset{} = Affairs.change_exam_mar(exam_mar)
    end
  end

  describe "exam_mark" do
    alias School.Affairs.ExamMark

    @valid_attrs %{class_id: 42, exam_id: 42, mark: 42, student_id: 42, subject_id: 42}
    @update_attrs %{class_id: 43, exam_id: 43, mark: 43, student_id: 43, subject_id: 43}
    @invalid_attrs %{class_id: nil, exam_id: nil, mark: nil, student_id: nil, subject_id: nil}

    def exam_mark_fixture(attrs \\ %{}) do
      {:ok, exam_mark} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_exam_mark()

      exam_mark
    end

    test "list_exam_mark/0 returns all exam_mark" do
      exam_mark = exam_mark_fixture()
      assert Affairs.list_exam_mark() == [exam_mark]
    end

    test "get_exam_mark!/1 returns the exam_mark with given id" do
      exam_mark = exam_mark_fixture()
      assert Affairs.get_exam_mark!(exam_mark.id) == exam_mark
    end

    test "create_exam_mark/1 with valid data creates a exam_mark" do
      assert {:ok, %ExamMark{} = exam_mark} = Affairs.create_exam_mark(@valid_attrs)
      assert exam_mark.class_id == 42
      assert exam_mark.exam_id == 42
      assert exam_mark.mark == 42
      assert exam_mark.student_id == 42
      assert exam_mark.subject_id == 42
    end

    test "create_exam_mark/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_exam_mark(@invalid_attrs)
    end

    test "update_exam_mark/2 with valid data updates the exam_mark" do
      exam_mark = exam_mark_fixture()
      assert {:ok, exam_mark} = Affairs.update_exam_mark(exam_mark, @update_attrs)
      assert %ExamMark{} = exam_mark
      assert exam_mark.class_id == 43
      assert exam_mark.exam_id == 43
      assert exam_mark.mark == 43
      assert exam_mark.student_id == 43
      assert exam_mark.subject_id == 43
    end

    test "update_exam_mark/2 with invalid data returns error changeset" do
      exam_mark = exam_mark_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_exam_mark(exam_mark, @invalid_attrs)
      assert exam_mark == Affairs.get_exam_mark!(exam_mark.id)
    end

    test "delete_exam_mark/1 deletes the exam_mark" do
      exam_mark = exam_mark_fixture()
      assert {:ok, %ExamMark{}} = Affairs.delete_exam_mark(exam_mark)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_exam_mark!(exam_mark.id) end
    end

    test "change_exam_mark/1 returns a exam_mark changeset" do
      exam_mark = exam_mark_fixture()
      assert %Ecto.Changeset{} = Affairs.change_exam_mark(exam_mark)
    end
  end

  describe "time_period" do
    alias School.Affairs.TimePeriod

    @valid_attrs %{time_end: ~T[14:00:00.000000], time_start: ~T[14:00:00.000000]}
    @update_attrs %{time_end: ~T[15:01:01.000000], time_start: ~T[15:01:01.000000]}
    @invalid_attrs %{time_end: nil, time_start: nil}

    def time_period_fixture(attrs \\ %{}) do
      {:ok, time_period} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_time_period()

      time_period
    end

    test "list_time_period/0 returns all time_period" do
      time_period = time_period_fixture()
      assert Affairs.list_time_period() == [time_period]
    end

    test "get_time_period!/1 returns the time_period with given id" do
      time_period = time_period_fixture()
      assert Affairs.get_time_period!(time_period.id) == time_period
    end

    test "create_time_period/1 with valid data creates a time_period" do
      assert {:ok, %TimePeriod{} = time_period} = Affairs.create_time_period(@valid_attrs)
      assert time_period.time_end == ~T[14:00:00.000000]
      assert time_period.time_start == ~T[14:00:00.000000]
    end

    test "create_time_period/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_time_period(@invalid_attrs)
    end

    test "update_time_period/2 with valid data updates the time_period" do
      time_period = time_period_fixture()
      assert {:ok, time_period} = Affairs.update_time_period(time_period, @update_attrs)
      assert %TimePeriod{} = time_period
      assert time_period.time_end == ~T[15:01:01.000000]
      assert time_period.time_start == ~T[15:01:01.000000]
    end

    test "update_time_period/2 with invalid data returns error changeset" do
      time_period = time_period_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_time_period(time_period, @invalid_attrs)
      assert time_period == Affairs.get_time_period!(time_period.id)
    end

    test "delete_time_period/1 deletes the time_period" do
      time_period = time_period_fixture()
      assert {:ok, %TimePeriod{}} = Affairs.delete_time_period(time_period)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_time_period!(time_period.id) end
    end

    test "change_time_period/1 returns a time_period changeset" do
      time_period = time_period_fixture()
      assert %Ecto.Changeset{} = Affairs.change_time_period(time_period)
    end
  end

  describe "head_count" do
    alias School.Affairs.HeadCount

    @valid_attrs %{class_id: 42, student_id: 42, subject_id: 42, targer_mark: 42}
    @update_attrs %{class_id: 43, student_id: 43, subject_id: 43, targer_mark: 43}
    @invalid_attrs %{class_id: nil, student_id: nil, subject_id: nil, targer_mark: nil}

    def head_count_fixture(attrs \\ %{}) do
      {:ok, head_count} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_head_count()

      head_count
    end

    test "list_head_count/0 returns all head_count" do
      head_count = head_count_fixture()
      assert Affairs.list_head_count() == [head_count]
    end

    test "get_head_count!/1 returns the head_count with given id" do
      head_count = head_count_fixture()
      assert Affairs.get_head_count!(head_count.id) == head_count
    end

    test "create_head_count/1 with valid data creates a head_count" do
      assert {:ok, %HeadCount{} = head_count} = Affairs.create_head_count(@valid_attrs)
      assert head_count.class_id == 42
      assert head_count.student_id == 42
      assert head_count.subject_id == 42
      assert head_count.targer_mark == 42
    end

    test "create_head_count/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_head_count(@invalid_attrs)
    end

    test "update_head_count/2 with valid data updates the head_count" do
      head_count = head_count_fixture()
      assert {:ok, head_count} = Affairs.update_head_count(head_count, @update_attrs)
      assert %HeadCount{} = head_count
      assert head_count.class_id == 43
      assert head_count.student_id == 43
      assert head_count.subject_id == 43
      assert head_count.targer_mark == 43
    end

    test "update_head_count/2 with invalid data returns error changeset" do
      head_count = head_count_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_head_count(head_count, @invalid_attrs)
      assert head_count == Affairs.get_head_count!(head_count.id)
    end

    test "delete_head_count/1 deletes the head_count" do
      head_count = head_count_fixture()
      assert {:ok, %HeadCount{}} = Affairs.delete_head_count(head_count)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_head_count!(head_count.id) end
    end

    test "change_head_count/1 returns a head_count changeset" do
      head_count = head_count_fixture()
      assert %Ecto.Changeset{} = Affairs.change_head_count(head_count)
    end
  end

  describe "head_counts" do
    alias School.Affairs.HeadCount

    @valid_attrs %{class_id: 42, student_id: 42, subject_id: 42, targer_mark: 42}
    @update_attrs %{class_id: 43, student_id: 43, subject_id: 43, targer_mark: 43}
    @invalid_attrs %{class_id: nil, student_id: nil, subject_id: nil, targer_mark: nil}

    def head_count_fixture(attrs \\ %{}) do
      {:ok, head_count} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_head_count()

      head_count
    end

    test "list_head_counts/0 returns all head_counts" do
      head_count = head_count_fixture()
      assert Affairs.list_head_counts() == [head_count]
    end

    test "get_head_count!/1 returns the head_count with given id" do
      head_count = head_count_fixture()
      assert Affairs.get_head_count!(head_count.id) == head_count
    end

    test "create_head_count/1 with valid data creates a head_count" do
      assert {:ok, %HeadCount{} = head_count} = Affairs.create_head_count(@valid_attrs)
      assert head_count.class_id == 42
      assert head_count.student_id == 42
      assert head_count.subject_id == 42
      assert head_count.targer_mark == 42
    end

    test "create_head_count/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_head_count(@invalid_attrs)
    end

    test "update_head_count/2 with valid data updates the head_count" do
      head_count = head_count_fixture()
      assert {:ok, head_count} = Affairs.update_head_count(head_count, @update_attrs)
      assert %HeadCount{} = head_count
      assert head_count.class_id == 43
      assert head_count.student_id == 43
      assert head_count.subject_id == 43
      assert head_count.targer_mark == 43
    end

    test "update_head_count/2 with invalid data returns error changeset" do
      head_count = head_count_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_head_count(head_count, @invalid_attrs)
      assert head_count == Affairs.get_head_count!(head_count.id)
    end

    test "delete_head_count/1 deletes the head_count" do
      head_count = head_count_fixture()
      assert {:ok, %HeadCount{}} = Affairs.delete_head_count(head_count)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_head_count!(head_count.id) end
    end

    test "change_head_count/1 returns a head_count changeset" do
      head_count = head_count_fixture()
      assert %Ecto.Changeset{} = Affairs.change_head_count(head_count)
    end
  end

  describe "teacher_period" do
    alias School.Affairs.TeacherPeriod

    @valid_attrs %{class_id: 42, day: "some day", end_time: ~T[14:00:00.000000], start_time: ~T[14:00:00.000000], subject_id: 42, teacher_id: 42}
    @update_attrs %{class_id: 43, day: "some updated day", end_time: ~T[15:01:01.000000], start_time: ~T[15:01:01.000000], subject_id: 43, teacher_id: 43}
    @invalid_attrs %{class_id: nil, day: nil, end_time: nil, start_time: nil, subject_id: nil, teacher_id: nil}

    def teacher_period_fixture(attrs \\ %{}) do
      {:ok, teacher_period} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher_period()

      teacher_period
    end

    test "list_teacher_period/0 returns all teacher_period" do
      teacher_period = teacher_period_fixture()
      assert Affairs.list_teacher_period() == [teacher_period]
    end

    test "get_teacher_period!/1 returns the teacher_period with given id" do
      teacher_period = teacher_period_fixture()
      assert Affairs.get_teacher_period!(teacher_period.id) == teacher_period
    end

    test "create_teacher_period/1 with valid data creates a teacher_period" do
      assert {:ok, %TeacherPeriod{} = teacher_period} = Affairs.create_teacher_period(@valid_attrs)
      assert teacher_period.class_id == 42
      assert teacher_period.day == "some day"
      assert teacher_period.end_time == ~T[14:00:00.000000]
      assert teacher_period.start_time == ~T[14:00:00.000000]
      assert teacher_period.subject_id == 42
      assert teacher_period.teacher_id == 42
    end

    test "create_teacher_period/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher_period(@invalid_attrs)
    end

    test "update_teacher_period/2 with valid data updates the teacher_period" do
      teacher_period = teacher_period_fixture()
      assert {:ok, teacher_period} = Affairs.update_teacher_period(teacher_period, @update_attrs)
      assert %TeacherPeriod{} = teacher_period
      assert teacher_period.class_id == 43
      assert teacher_period.day == "some updated day"
      assert teacher_period.end_time == ~T[15:01:01.000000]
      assert teacher_period.start_time == ~T[15:01:01.000000]
      assert teacher_period.subject_id == 43
      assert teacher_period.teacher_id == 43
    end

    test "update_teacher_period/2 with invalid data returns error changeset" do
      teacher_period = teacher_period_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher_period(teacher_period, @invalid_attrs)
      assert teacher_period == Affairs.get_teacher_period!(teacher_period.id)
    end

    test "delete_teacher_period/1 deletes the teacher_period" do
      teacher_period = teacher_period_fixture()
      assert {:ok, %TeacherPeriod{}} = Affairs.delete_teacher_period(teacher_period)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher_period!(teacher_period.id) end
    end

    test "change_teacher_period/1 returns a teacher_period changeset" do
      teacher_period = teacher_period_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher_period(teacher_period)
    end
  end

  describe "co_grade" do
    alias School.Affairs.CoGrade

    @valid_attrs %{gpa: "120.5", max: 42, min: 42, name: "some name"}
    @update_attrs %{gpa: "456.7", max: 43, min: 43, name: "some updated name"}
    @invalid_attrs %{gpa: nil, max: nil, min: nil, name: nil}

    def co_grade_fixture(attrs \\ %{}) do
      {:ok, co_grade} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_co_grade()

      co_grade
    end

    test "list_co_grade/0 returns all co_grade" do
      co_grade = co_grade_fixture()
      assert Affairs.list_co_grade() == [co_grade]
    end

    test "get_co_grade!/1 returns the co_grade with given id" do
      co_grade = co_grade_fixture()
      assert Affairs.get_co_grade!(co_grade.id) == co_grade
    end

    test "create_co_grade/1 with valid data creates a co_grade" do
      assert {:ok, %CoGrade{} = co_grade} = Affairs.create_co_grade(@valid_attrs)
      assert co_grade.gpa == Decimal.new("120.5")
      assert co_grade.max == 42
      assert co_grade.min == 42
      assert co_grade.name == "some name"
    end

    test "create_co_grade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_co_grade(@invalid_attrs)
    end

    test "update_co_grade/2 with valid data updates the co_grade" do
      co_grade = co_grade_fixture()
      assert {:ok, co_grade} = Affairs.update_co_grade(co_grade, @update_attrs)
      assert %CoGrade{} = co_grade
      assert co_grade.gpa == Decimal.new("456.7")
      assert co_grade.max == 43
      assert co_grade.min == 43
      assert co_grade.name == "some updated name"
    end

    test "update_co_grade/2 with invalid data returns error changeset" do
      co_grade = co_grade_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_co_grade(co_grade, @invalid_attrs)
      assert co_grade == Affairs.get_co_grade!(co_grade.id)
    end

    test "delete_co_grade/1 deletes the co_grade" do
      co_grade = co_grade_fixture()
      assert {:ok, %CoGrade{}} = Affairs.delete_co_grade(co_grade)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_co_grade!(co_grade.id) end
    end

    test "change_co_grade/1 returns a co_grade changeset" do
      co_grade = co_grade_fixture()
      assert %Ecto.Changeset{} = Affairs.change_co_grade(co_grade)
    end
  end

  describe "school_job" do
    alias School.Affairs.ScSchoolJob

    @valid_attrs %{cdesc: "some cdesc", code: "some code", description: "some description"}
    @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description"}
    @invalid_attrs %{cdesc: nil, code: nil, description: nil}

    def sc_school_job_fixture(attrs \\ %{}) do
      {:ok, sc_school_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_sc_school_job()

      sc_school_job
    end

    test "list_school_job/0 returns all school_job" do
      sc_school_job = sc_school_job_fixture()
      assert Affairs.list_school_job() == [sc_school_job]
    end

    test "get_sc_school_job!/1 returns the sc_school_job with given id" do
      sc_school_job = sc_school_job_fixture()
      assert Affairs.get_sc_school_job!(sc_school_job.id) == sc_school_job
    end

    test "create_sc_school_job/1 with valid data creates a sc_school_job" do
      assert {:ok, %ScSchoolJob{} = sc_school_job} = Affairs.create_sc_school_job(@valid_attrs)
      assert sc_school_job.cdesc == "some cdesc"
      assert sc_school_job.code == "some code"
      assert sc_school_job.description == "some description"
    end

    test "create_sc_school_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_sc_school_job(@invalid_attrs)
    end

    test "update_sc_school_job/2 with valid data updates the sc_school_job" do
      sc_school_job = sc_school_job_fixture()
      assert {:ok, sc_school_job} = Affairs.update_sc_school_job(sc_school_job, @update_attrs)
      assert %ScSchoolJob{} = sc_school_job
      assert sc_school_job.cdesc == "some updated cdesc"
      assert sc_school_job.code == "some updated code"
      assert sc_school_job.description == "some updated description"
    end

    test "update_sc_school_job/2 with invalid data returns error changeset" do
      sc_school_job = sc_school_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_sc_school_job(sc_school_job, @invalid_attrs)
      assert sc_school_job == Affairs.get_sc_school_job!(sc_school_job.id)
    end

    test "delete_sc_school_job/1 deletes the sc_school_job" do
      sc_school_job = sc_school_job_fixture()
      assert {:ok, %ScSchoolJob{}} = Affairs.delete_sc_school_job(sc_school_job)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_sc_school_job!(sc_school_job.id) end
    end

    test "change_sc_school_job/1 returns a sc_school_job changeset" do
      sc_school_job = sc_school_job_fixture()
      assert %Ecto.Changeset{} = Affairs.change_sc_school_job(sc_school_job)
    end
  end

  describe "school_job" do
    alias School.Affairs.SchoolJob

    @valid_attrs %{cdesc: "some cdesc", code: "some code", description: "some description"}
    @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description"}
    @invalid_attrs %{cdesc: nil, code: nil, description: nil}

    def school_job_fixture(attrs \\ %{}) do
      {:ok, school_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_school_job()

      school_job
    end

    test "list_school_job/0 returns all school_job" do
      school_job = school_job_fixture()
      assert Affairs.list_school_job() == [school_job]
    end

    test "get_school_job!/1 returns the school_job with given id" do
      school_job = school_job_fixture()
      assert Affairs.get_school_job!(school_job.id) == school_job
    end

    test "create_school_job/1 with valid data creates a school_job" do
      assert {:ok, %SchoolJob{} = school_job} = Affairs.create_school_job(@valid_attrs)
      assert school_job.cdesc == "some cdesc"
      assert school_job.code == "some code"
      assert school_job.description == "some description"
    end

    test "create_school_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_school_job(@invalid_attrs)
    end

    test "update_school_job/2 with valid data updates the school_job" do
      school_job = school_job_fixture()
      assert {:ok, school_job} = Affairs.update_school_job(school_job, @update_attrs)
      assert %SchoolJob{} = school_job
      assert school_job.cdesc == "some updated cdesc"
      assert school_job.code == "some updated code"
      assert school_job.description == "some updated description"
    end

    test "update_school_job/2 with invalid data returns error changeset" do
      school_job = school_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_school_job(school_job, @invalid_attrs)
      assert school_job == Affairs.get_school_job!(school_job.id)
    end

    test "delete_school_job/1 deletes the school_job" do
      school_job = school_job_fixture()
      assert {:ok, %SchoolJob{}} = Affairs.delete_school_job(school_job)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_school_job!(school_job.id) end
    end

    test "change_school_job/1 returns a school_job changeset" do
      school_job = school_job_fixture()
      assert %Ecto.Changeset{} = Affairs.change_school_job(school_job)
    end
  end

  describe "cocurriculum_job" do
    alias School.Affairs.CoCurriculumJob

    @valid_attrs %{cdesc: "some cdesc", code: "some code", description: "some description"}
    @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description"}
    @invalid_attrs %{cdesc: nil, code: nil, description: nil}

    def co_curriculum_job_fixture(attrs \\ %{}) do
      {:ok, co_curriculum_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_co_curriculum_job()

      co_curriculum_job
    end

    test "list_cocurriculum_job/0 returns all cocurriculum_job" do
      co_curriculum_job = co_curriculum_job_fixture()
      assert Affairs.list_cocurriculum_job() == [co_curriculum_job]
    end

    test "get_co_curriculum_job!/1 returns the co_curriculum_job with given id" do
      co_curriculum_job = co_curriculum_job_fixture()
      assert Affairs.get_co_curriculum_job!(co_curriculum_job.id) == co_curriculum_job
    end

    test "create_co_curriculum_job/1 with valid data creates a co_curriculum_job" do
      assert {:ok, %CoCurriculumJob{} = co_curriculum_job} = Affairs.create_co_curriculum_job(@valid_attrs)
      assert co_curriculum_job.cdesc == "some cdesc"
      assert co_curriculum_job.code == "some code"
      assert co_curriculum_job.description == "some description"
    end

    test "create_co_curriculum_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_co_curriculum_job(@invalid_attrs)
    end

    test "update_co_curriculum_job/2 with valid data updates the co_curriculum_job" do
      co_curriculum_job = co_curriculum_job_fixture()
      assert {:ok, co_curriculum_job} = Affairs.update_co_curriculum_job(co_curriculum_job, @update_attrs)
      assert %CoCurriculumJob{} = co_curriculum_job
      assert co_curriculum_job.cdesc == "some updated cdesc"
      assert co_curriculum_job.code == "some updated code"
      assert co_curriculum_job.description == "some updated description"
    end

    test "update_co_curriculum_job/2 with invalid data returns error changeset" do
      co_curriculum_job = co_curriculum_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_co_curriculum_job(co_curriculum_job, @invalid_attrs)
      assert co_curriculum_job == Affairs.get_co_curriculum_job!(co_curriculum_job.id)
    end

    test "delete_co_curriculum_job/1 deletes the co_curriculum_job" do
      co_curriculum_job = co_curriculum_job_fixture()
      assert {:ok, %CoCurriculumJob{}} = Affairs.delete_co_curriculum_job(co_curriculum_job)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_co_curriculum_job!(co_curriculum_job.id) end
    end

    test "change_co_curriculum_job/1 returns a co_curriculum_job changeset" do
      co_curriculum_job = co_curriculum_job_fixture()
      assert %Ecto.Changeset{} = Affairs.change_co_curriculum_job(co_curriculum_job)
    end
  end

  describe "hem_job" do
    alias School.Affairs.HemJob

    @valid_attrs %{cdesc: "some cdesc", code: "some code", description: "some description"}
    @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description"}
    @invalid_attrs %{cdesc: nil, code: nil, description: nil}

    def hem_job_fixture(attrs \\ %{}) do
      {:ok, hem_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_hem_job()

      hem_job
    end

    test "list_hem_job/0 returns all hem_job" do
      hem_job = hem_job_fixture()
      assert Affairs.list_hem_job() == [hem_job]
    end

    test "get_hem_job!/1 returns the hem_job with given id" do
      hem_job = hem_job_fixture()
      assert Affairs.get_hem_job!(hem_job.id) == hem_job
    end

    test "create_hem_job/1 with valid data creates a hem_job" do
      assert {:ok, %HemJob{} = hem_job} = Affairs.create_hem_job(@valid_attrs)
      assert hem_job.cdesc == "some cdesc"
      assert hem_job.code == "some code"
      assert hem_job.description == "some description"
    end

    test "create_hem_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_hem_job(@invalid_attrs)
    end

    test "update_hem_job/2 with valid data updates the hem_job" do
      hem_job = hem_job_fixture()
      assert {:ok, hem_job} = Affairs.update_hem_job(hem_job, @update_attrs)
      assert %HemJob{} = hem_job
      assert hem_job.cdesc == "some updated cdesc"
      assert hem_job.code == "some updated code"
      assert hem_job.description == "some updated description"
    end

    test "update_hem_job/2 with invalid data returns error changeset" do
      hem_job = hem_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_hem_job(hem_job, @invalid_attrs)
      assert hem_job == Affairs.get_hem_job!(hem_job.id)
    end

    test "delete_hem_job/1 deletes the hem_job" do
      hem_job = hem_job_fixture()
      assert {:ok, %HemJob{}} = Affairs.delete_hem_job(hem_job)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_hem_job!(hem_job.id) end
    end

    test "change_hem_job/1 returns a hem_job changeset" do
      hem_job = hem_job_fixture()
      assert %Ecto.Changeset{} = Affairs.change_hem_job(hem_job)
    end
  end

  describe "absent_reason" do
    alias School.Affairs.AbsentReason

    @valid_attrs %{code: "some code", description: "some description", type: "some type"}
    @update_attrs %{code: "some updated code", description: "some updated description", type: "some updated type"}
    @invalid_attrs %{code: nil, description: nil, type: nil}

    def absent_reason_fixture(attrs \\ %{}) do
      {:ok, absent_reason} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_absent_reason()

      absent_reason
    end

    test "list_absent_reason/0 returns all absent_reason" do
      absent_reason = absent_reason_fixture()
      assert Affairs.list_absent_reason() == [absent_reason]
    end

    test "get_absent_reason!/1 returns the absent_reason with given id" do
      absent_reason = absent_reason_fixture()
      assert Affairs.get_absent_reason!(absent_reason.id) == absent_reason
    end

    test "create_absent_reason/1 with valid data creates a absent_reason" do
      assert {:ok, %AbsentReason{} = absent_reason} = Affairs.create_absent_reason(@valid_attrs)
      assert absent_reason.code == "some code"
      assert absent_reason.description == "some description"
      assert absent_reason.type == "some type"
    end

    test "create_absent_reason/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_absent_reason(@invalid_attrs)
    end

    test "update_absent_reason/2 with valid data updates the absent_reason" do
      absent_reason = absent_reason_fixture()
      assert {:ok, absent_reason} = Affairs.update_absent_reason(absent_reason, @update_attrs)
      assert %AbsentReason{} = absent_reason
      assert absent_reason.code == "some updated code"
      assert absent_reason.description == "some updated description"
      assert absent_reason.type == "some updated type"
    end

    test "update_absent_reason/2 with invalid data returns error changeset" do
      absent_reason = absent_reason_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_absent_reason(absent_reason, @invalid_attrs)
      assert absent_reason == Affairs.get_absent_reason!(absent_reason.id)
    end

    test "delete_absent_reason/1 deletes the absent_reason" do
      absent_reason = absent_reason_fixture()
      assert {:ok, %AbsentReason{}} = Affairs.delete_absent_reason(absent_reason)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_absent_reason!(absent_reason.id) end
    end

    test "change_absent_reason/1 returns a absent_reason changeset" do
      absent_reason = absent_reason_fixture()
      assert %Ecto.Changeset{} = Affairs.change_absent_reason(absent_reason)
    end
  end

  describe "teacher_school_job" do
    alias School.Affairs.TeacherSchoolJob

    @valid_attrs %{school_job_id: 42, semester_id: 42, teacher_id: 42}
    @update_attrs %{school_job_id: 43, semester_id: 43, teacher_id: 43}
    @invalid_attrs %{school_job_id: nil, semester_id: nil, teacher_id: nil}

    def teacher_school_job_fixture(attrs \\ %{}) do
      {:ok, teacher_school_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher_school_job()

      teacher_school_job
    end

    test "list_teacher_school_job/0 returns all teacher_school_job" do
      teacher_school_job = teacher_school_job_fixture()
      assert Affairs.list_teacher_school_job() == [teacher_school_job]
    end

    test "get_teacher_school_job!/1 returns the teacher_school_job with given id" do
      teacher_school_job = teacher_school_job_fixture()
      assert Affairs.get_teacher_school_job!(teacher_school_job.id) == teacher_school_job
    end

    test "create_teacher_school_job/1 with valid data creates a teacher_school_job" do
      assert {:ok, %TeacherSchoolJob{} = teacher_school_job} = Affairs.create_teacher_school_job(@valid_attrs)
      assert teacher_school_job.school_job_id == 42
      assert teacher_school_job.semester_id == 42
      assert teacher_school_job.teacher_id == 42
    end

    test "create_teacher_school_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher_school_job(@invalid_attrs)
    end

    test "update_teacher_school_job/2 with valid data updates the teacher_school_job" do
      teacher_school_job = teacher_school_job_fixture()
      assert {:ok, teacher_school_job} = Affairs.update_teacher_school_job(teacher_school_job, @update_attrs)
      assert %TeacherSchoolJob{} = teacher_school_job
      assert teacher_school_job.school_job_id == 43
      assert teacher_school_job.semester_id == 43
      assert teacher_school_job.teacher_id == 43
    end

    test "update_teacher_school_job/2 with invalid data returns error changeset" do
      teacher_school_job = teacher_school_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher_school_job(teacher_school_job, @invalid_attrs)
      assert teacher_school_job == Affairs.get_teacher_school_job!(teacher_school_job.id)
    end

    test "delete_teacher_school_job/1 deletes the teacher_school_job" do
      teacher_school_job = teacher_school_job_fixture()
      assert {:ok, %TeacherSchoolJob{}} = Affairs.delete_teacher_school_job(teacher_school_job)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher_school_job!(teacher_school_job.id) end
    end

    test "change_teacher_school_job/1 returns a teacher_school_job changeset" do
      teacher_school_job = teacher_school_job_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher_school_job(teacher_school_job)
    end
  end

  describe "teacher_co_curriculum_job" do
    alias School.Affairs.TeacherCoCurriculumJob

    @valid_attrs %{co_curriculum_job_id: 42, semester_id: 42, teacher_id: 42}
    @update_attrs %{co_curriculum_job_id: 43, semester_id: 43, teacher_id: 43}
    @invalid_attrs %{co_curriculum_job_id: nil, semester_id: nil, teacher_id: nil}

    def teacher_co_curriculum_job_fixture(attrs \\ %{}) do
      {:ok, teacher_co_curriculum_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher_co_curriculum_job()

      teacher_co_curriculum_job
    end

    test "list_teacher_co_curriculum_job/0 returns all teacher_co_curriculum_job" do
      teacher_co_curriculum_job = teacher_co_curriculum_job_fixture()
      assert Affairs.list_teacher_co_curriculum_job() == [teacher_co_curriculum_job]
    end

    test "get_teacher_co_curriculum_job!/1 returns the teacher_co_curriculum_job with given id" do
      teacher_co_curriculum_job = teacher_co_curriculum_job_fixture()
      assert Affairs.get_teacher_co_curriculum_job!(teacher_co_curriculum_job.id) == teacher_co_curriculum_job
    end

    test "create_teacher_co_curriculum_job/1 with valid data creates a teacher_co_curriculum_job" do
      assert {:ok, %TeacherCoCurriculumJob{} = teacher_co_curriculum_job} = Affairs.create_teacher_co_curriculum_job(@valid_attrs)
      assert teacher_co_curriculum_job.co_curriculum_job_id == 42
      assert teacher_co_curriculum_job.semester_id == 42
      assert teacher_co_curriculum_job.teacher_id == 42
    end

    test "create_teacher_co_curriculum_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher_co_curriculum_job(@invalid_attrs)
    end

    test "update_teacher_co_curriculum_job/2 with valid data updates the teacher_co_curriculum_job" do
      teacher_co_curriculum_job = teacher_co_curriculum_job_fixture()
      assert {:ok, teacher_co_curriculum_job} = Affairs.update_teacher_co_curriculum_job(teacher_co_curriculum_job, @update_attrs)
      assert %TeacherCoCurriculumJob{} = teacher_co_curriculum_job
      assert teacher_co_curriculum_job.co_curriculum_job_id == 43
      assert teacher_co_curriculum_job.semester_id == 43
      assert teacher_co_curriculum_job.teacher_id == 43
    end

    test "update_teacher_co_curriculum_job/2 with invalid data returns error changeset" do
      teacher_co_curriculum_job = teacher_co_curriculum_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher_co_curriculum_job(teacher_co_curriculum_job, @invalid_attrs)
      assert teacher_co_curriculum_job == Affairs.get_teacher_co_curriculum_job!(teacher_co_curriculum_job.id)
    end

    test "delete_teacher_co_curriculum_job/1 deletes the teacher_co_curriculum_job" do
      teacher_co_curriculum_job = teacher_co_curriculum_job_fixture()
      assert {:ok, %TeacherCoCurriculumJob{}} = Affairs.delete_teacher_co_curriculum_job(teacher_co_curriculum_job)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher_co_curriculum_job!(teacher_co_curriculum_job.id) end
    end

    test "change_teacher_co_curriculum_job/1 returns a teacher_co_curriculum_job changeset" do
      teacher_co_curriculum_job = teacher_co_curriculum_job_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher_co_curriculum_job(teacher_co_curriculum_job)
    end
  end

  describe "teacher_hem_job" do
    alias School.Affairs.TeacherHemJob

    @valid_attrs %{hem_job_id: 42, semester_id: 42, teacher_id: 42}
    @update_attrs %{hem_job_id: 43, semester_id: 43, teacher_id: 43}
    @invalid_attrs %{hem_job_id: nil, semester_id: nil, teacher_id: nil}

    def teacher_hem_job_fixture(attrs \\ %{}) do
      {:ok, teacher_hem_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher_hem_job()

      teacher_hem_job
    end

    test "list_teacher_hem_job/0 returns all teacher_hem_job" do
      teacher_hem_job = teacher_hem_job_fixture()
      assert Affairs.list_teacher_hem_job() == [teacher_hem_job]
    end

    test "get_teacher_hem_job!/1 returns the teacher_hem_job with given id" do
      teacher_hem_job = teacher_hem_job_fixture()
      assert Affairs.get_teacher_hem_job!(teacher_hem_job.id) == teacher_hem_job
    end

    test "create_teacher_hem_job/1 with valid data creates a teacher_hem_job" do
      assert {:ok, %TeacherHemJob{} = teacher_hem_job} = Affairs.create_teacher_hem_job(@valid_attrs)
      assert teacher_hem_job.hem_job_id == 42
      assert teacher_hem_job.semester_id == 42
      assert teacher_hem_job.teacher_id == 42
    end

    test "create_teacher_hem_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher_hem_job(@invalid_attrs)
    end

    test "update_teacher_hem_job/2 with valid data updates the teacher_hem_job" do
      teacher_hem_job = teacher_hem_job_fixture()
      assert {:ok, teacher_hem_job} = Affairs.update_teacher_hem_job(teacher_hem_job, @update_attrs)
      assert %TeacherHemJob{} = teacher_hem_job
      assert teacher_hem_job.hem_job_id == 43
      assert teacher_hem_job.semester_id == 43
      assert teacher_hem_job.teacher_id == 43
    end

    test "update_teacher_hem_job/2 with invalid data returns error changeset" do
      teacher_hem_job = teacher_hem_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher_hem_job(teacher_hem_job, @invalid_attrs)
      assert teacher_hem_job == Affairs.get_teacher_hem_job!(teacher_hem_job.id)
    end

    test "delete_teacher_hem_job/1 deletes the teacher_hem_job" do
      teacher_hem_job = teacher_hem_job_fixture()
      assert {:ok, %TeacherHemJob{}} = Affairs.delete_teacher_hem_job(teacher_hem_job)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher_hem_job!(teacher_hem_job.id) end
    end

    test "change_teacher_hem_job/1 returns a teacher_hem_job changeset" do
      teacher_hem_job = teacher_hem_job_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher_hem_job(teacher_hem_job)
    end
  end

  describe "teacher_absent_reason" do
    alias School.Affairs.TeacherAbsentReason

    @valid_attrs %{absent_reason_id: 42, semester_id: 42, teacher_id: 42}
    @update_attrs %{absent_reason_id: 43, semester_id: 43, teacher_id: 43}
    @invalid_attrs %{absent_reason_id: nil, semester_id: nil, teacher_id: nil}

    def teacher_absent_reason_fixture(attrs \\ %{}) do
      {:ok, teacher_absent_reason} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_teacher_absent_reason()

      teacher_absent_reason
    end

    test "list_teacher_absent_reason/0 returns all teacher_absent_reason" do
      teacher_absent_reason = teacher_absent_reason_fixture()
      assert Affairs.list_teacher_absent_reason() == [teacher_absent_reason]
    end

    test "get_teacher_absent_reason!/1 returns the teacher_absent_reason with given id" do
      teacher_absent_reason = teacher_absent_reason_fixture()
      assert Affairs.get_teacher_absent_reason!(teacher_absent_reason.id) == teacher_absent_reason
    end

    test "create_teacher_absent_reason/1 with valid data creates a teacher_absent_reason" do
      assert {:ok, %TeacherAbsentReason{} = teacher_absent_reason} = Affairs.create_teacher_absent_reason(@valid_attrs)
      assert teacher_absent_reason.absent_reason_id == 42
      assert teacher_absent_reason.semester_id == 42
      assert teacher_absent_reason.teacher_id == 42
    end

    test "create_teacher_absent_reason/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_teacher_absent_reason(@invalid_attrs)
    end

    test "update_teacher_absent_reason/2 with valid data updates the teacher_absent_reason" do
      teacher_absent_reason = teacher_absent_reason_fixture()
      assert {:ok, teacher_absent_reason} = Affairs.update_teacher_absent_reason(teacher_absent_reason, @update_attrs)
      assert %TeacherAbsentReason{} = teacher_absent_reason
      assert teacher_absent_reason.absent_reason_id == 43
      assert teacher_absent_reason.semester_id == 43
      assert teacher_absent_reason.teacher_id == 43
    end

    test "update_teacher_absent_reason/2 with invalid data returns error changeset" do
      teacher_absent_reason = teacher_absent_reason_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_teacher_absent_reason(teacher_absent_reason, @invalid_attrs)
      assert teacher_absent_reason == Affairs.get_teacher_absent_reason!(teacher_absent_reason.id)
    end

    test "delete_teacher_absent_reason/1 deletes the teacher_absent_reason" do
      teacher_absent_reason = teacher_absent_reason_fixture()
      assert {:ok, %TeacherAbsentReason{}} = Affairs.delete_teacher_absent_reason(teacher_absent_reason)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_teacher_absent_reason!(teacher_absent_reason.id) end
    end

    test "change_teacher_absent_reason/1 returns a teacher_absent_reason changeset" do
      teacher_absent_reason = teacher_absent_reason_fixture()
      assert %Ecto.Changeset{} = Affairs.change_teacher_absent_reason(teacher_absent_reason)
    end
  end

  describe "project_nilam" do
    alias School.Affairs.ProjectNilam

    @valid_attrs %{below_satisfy: 42, count_page: 42, import_from_library: 42, member_reading_quantity: 42, page: 42, standard_id: 42}
    @update_attrs %{below_satisfy: 43, count_page: 43, import_from_library: 43, member_reading_quantity: 43, page: 43, standard_id: 43}
    @invalid_attrs %{below_satisfy: nil, count_page: nil, import_from_library: nil, member_reading_quantity: nil, page: nil, standard_id: nil}

    def project_nilam_fixture(attrs \\ %{}) do
      {:ok, project_nilam} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_project_nilam()

      project_nilam
    end

    test "list_project_nilam/0 returns all project_nilam" do
      project_nilam = project_nilam_fixture()
      assert Affairs.list_project_nilam() == [project_nilam]
    end

    test "get_project_nilam!/1 returns the project_nilam with given id" do
      project_nilam = project_nilam_fixture()
      assert Affairs.get_project_nilam!(project_nilam.id) == project_nilam
    end

    test "create_project_nilam/1 with valid data creates a project_nilam" do
      assert {:ok, %ProjectNilam{} = project_nilam} = Affairs.create_project_nilam(@valid_attrs)
      assert project_nilam.below_satisfy == 42
      assert project_nilam.count_page == 42
      assert project_nilam.import_from_library == 42
      assert project_nilam.member_reading_quantity == 42
      assert project_nilam.page == 42
      assert project_nilam.standard_id == 42
    end

    test "create_project_nilam/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_project_nilam(@invalid_attrs)
    end

    test "update_project_nilam/2 with valid data updates the project_nilam" do
      project_nilam = project_nilam_fixture()
      assert {:ok, project_nilam} = Affairs.update_project_nilam(project_nilam, @update_attrs)
      assert %ProjectNilam{} = project_nilam
      assert project_nilam.below_satisfy == 43
      assert project_nilam.count_page == 43
      assert project_nilam.import_from_library == 43
      assert project_nilam.member_reading_quantity == 43
      assert project_nilam.page == 43
      assert project_nilam.standard_id == 43
    end

    test "update_project_nilam/2 with invalid data returns error changeset" do
      project_nilam = project_nilam_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_project_nilam(project_nilam, @invalid_attrs)
      assert project_nilam == Affairs.get_project_nilam!(project_nilam.id)
    end

    test "delete_project_nilam/1 deletes the project_nilam" do
      project_nilam = project_nilam_fixture()
      assert {:ok, %ProjectNilam{}} = Affairs.delete_project_nilam(project_nilam)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_project_nilam!(project_nilam.id) end
    end

    test "change_project_nilam/1 returns a project_nilam changeset" do
      project_nilam = project_nilam_fixture()
      assert %Ecto.Changeset{} = Affairs.change_project_nilam(project_nilam)
    end
  end

  describe "jauhari" do
    alias School.Affairs.Jauhari

    @valid_attrs %{max: 42, min: 42, prize: "some prize"}
    @update_attrs %{max: 43, min: 43, prize: "some updated prize"}
    @invalid_attrs %{max: nil, min: nil, prize: nil}

    def jauhari_fixture(attrs \\ %{}) do
      {:ok, jauhari} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_jauhari()

      jauhari
    end

    test "list_jauhari/0 returns all jauhari" do
      jauhari = jauhari_fixture()
      assert Affairs.list_jauhari() == [jauhari]
    end

    test "get_jauhari!/1 returns the jauhari with given id" do
      jauhari = jauhari_fixture()
      assert Affairs.get_jauhari!(jauhari.id) == jauhari
    end

    test "create_jauhari/1 with valid data creates a jauhari" do
      assert {:ok, %Jauhari{} = jauhari} = Affairs.create_jauhari(@valid_attrs)
      assert jauhari.max == 42
      assert jauhari.min == 42
      assert jauhari.prize == "some prize"
    end

    test "create_jauhari/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_jauhari(@invalid_attrs)
    end

    test "update_jauhari/2 with valid data updates the jauhari" do
      jauhari = jauhari_fixture()
      assert {:ok, jauhari} = Affairs.update_jauhari(jauhari, @update_attrs)
      assert %Jauhari{} = jauhari
      assert jauhari.max == 43
      assert jauhari.min == 43
      assert jauhari.prize == "some updated prize"
    end

    test "update_jauhari/2 with invalid data returns error changeset" do
      jauhari = jauhari_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_jauhari(jauhari, @invalid_attrs)
      assert jauhari == Affairs.get_jauhari!(jauhari.id)
    end

    test "delete_jauhari/1 deletes the jauhari" do
      jauhari = jauhari_fixture()
      assert {:ok, %Jauhari{}} = Affairs.delete_jauhari(jauhari)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_jauhari!(jauhari.id) end
    end

    test "change_jauhari/1 returns a jauhari changeset" do
      jauhari = jauhari_fixture()
      assert %Ecto.Changeset{} = Affairs.change_jauhari(jauhari)
    end
  end

  describe "rakan" do
    alias School.Affairs.Rakan

    @valid_attrs %{max: 42, min: 42, prize: "some prize", standard_id: 42}
    @update_attrs %{max: 43, min: 43, prize: "some updated prize", standard_id: 43}
    @invalid_attrs %{max: nil, min: nil, prize: nil, standard_id: nil}

    def rakan_fixture(attrs \\ %{}) do
      {:ok, rakan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_rakan()

      rakan
    end

    test "list_rakan/0 returns all rakan" do
      rakan = rakan_fixture()
      assert Affairs.list_rakan() == [rakan]
    end

    test "get_rakan!/1 returns the rakan with given id" do
      rakan = rakan_fixture()
      assert Affairs.get_rakan!(rakan.id) == rakan
    end

    test "create_rakan/1 with valid data creates a rakan" do
      assert {:ok, %Rakan{} = rakan} = Affairs.create_rakan(@valid_attrs)
      assert rakan.max == 42
      assert rakan.min == 42
      assert rakan.prize == "some prize"
      assert rakan.standard_id == 42
    end

    test "create_rakan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_rakan(@invalid_attrs)
    end

    test "update_rakan/2 with valid data updates the rakan" do
      rakan = rakan_fixture()
      assert {:ok, rakan} = Affairs.update_rakan(rakan, @update_attrs)
      assert %Rakan{} = rakan
      assert rakan.max == 43
      assert rakan.min == 43
      assert rakan.prize == "some updated prize"
      assert rakan.standard_id == 43
    end

    test "update_rakan/2 with invalid data returns error changeset" do
      rakan = rakan_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_rakan(rakan, @invalid_attrs)
      assert rakan == Affairs.get_rakan!(rakan.id)
    end

    test "delete_rakan/1 deletes the rakan" do
      rakan = rakan_fixture()
      assert {:ok, %Rakan{}} = Affairs.delete_rakan(rakan)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_rakan!(rakan.id) end
    end

    test "change_rakan/1 returns a rakan changeset" do
      rakan = rakan_fixture()
      assert %Ecto.Changeset{} = Affairs.change_rakan(rakan)
    end
  end

  describe "standard_subject" do
    alias School.Affairs.StandardSubject

    @valid_attrs %{semester_id: 42, standard_id: 42, subject_id: 42, year: "some year"}
    @update_attrs %{semester_id: 43, standard_id: 43, subject_id: 43, year: "some updated year"}
    @invalid_attrs %{semester_id: nil, standard_id: nil, subject_id: nil, year: nil}

    def standard_subject_fixture(attrs \\ %{}) do
      {:ok, standard_subject} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_standard_subject()

      standard_subject
    end

    test "list_standard_subject/0 returns all standard_subject" do
      standard_subject = standard_subject_fixture()
      assert Affairs.list_standard_subject() == [standard_subject]
    end

    test "get_standard_subject!/1 returns the standard_subject with given id" do
      standard_subject = standard_subject_fixture()
      assert Affairs.get_standard_subject!(standard_subject.id) == standard_subject
    end

    test "create_standard_subject/1 with valid data creates a standard_subject" do
      assert {:ok, %StandardSubject{} = standard_subject} = Affairs.create_standard_subject(@valid_attrs)
      assert standard_subject.semester_id == 42
      assert standard_subject.standard_id == 42
      assert standard_subject.subject_id == 42
      assert standard_subject.year == "some year"
    end

    test "create_standard_subject/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_standard_subject(@invalid_attrs)
    end

    test "update_standard_subject/2 with valid data updates the standard_subject" do
      standard_subject = standard_subject_fixture()
      assert {:ok, standard_subject} = Affairs.update_standard_subject(standard_subject, @update_attrs)
      assert %StandardSubject{} = standard_subject
      assert standard_subject.semester_id == 43
      assert standard_subject.standard_id == 43
      assert standard_subject.subject_id == 43
      assert standard_subject.year == "some updated year"
    end

    test "update_standard_subject/2 with invalid data returns error changeset" do
      standard_subject = standard_subject_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_standard_subject(standard_subject, @invalid_attrs)
      assert standard_subject == Affairs.get_standard_subject!(standard_subject.id)
    end

    test "delete_standard_subject/1 deletes the standard_subject" do
      standard_subject = standard_subject_fixture()
      assert {:ok, %StandardSubject{}} = Affairs.delete_standard_subject(standard_subject)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_standard_subject!(standard_subject.id) end
    end

    test "change_standard_subject/1 returns a standard_subject changeset" do
      standard_subject = standard_subject_fixture()
      assert %Ecto.Changeset{} = Affairs.change_standard_subject(standard_subject)
    end
  end

  describe "subject_teach_class" do
    alias School.Affairs.SubjectTeachClass

    @valid_attrs %{class_id: 42, standard_id: 42, subject_id: 42, teacher_id: 42}
    @update_attrs %{class_id: 43, standard_id: 43, subject_id: 43, teacher_id: 43}
    @invalid_attrs %{class_id: nil, standard_id: nil, subject_id: nil, teacher_id: nil}

    def subject_teach_class_fixture(attrs \\ %{}) do
      {:ok, subject_teach_class} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Affairs.create_subject_teach_class()

      subject_teach_class
    end

    test "list_subject_teach_class/0 returns all subject_teach_class" do
      subject_teach_class = subject_teach_class_fixture()
      assert Affairs.list_subject_teach_class() == [subject_teach_class]
    end

    test "get_subject_teach_class!/1 returns the subject_teach_class with given id" do
      subject_teach_class = subject_teach_class_fixture()
      assert Affairs.get_subject_teach_class!(subject_teach_class.id) == subject_teach_class
    end

    test "create_subject_teach_class/1 with valid data creates a subject_teach_class" do
      assert {:ok, %SubjectTeachClass{} = subject_teach_class} = Affairs.create_subject_teach_class(@valid_attrs)
      assert subject_teach_class.class_id == 42
      assert subject_teach_class.standard_id == 42
      assert subject_teach_class.subject_id == 42
      assert subject_teach_class.teacher_id == 42
    end

    test "create_subject_teach_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affairs.create_subject_teach_class(@invalid_attrs)
    end

    test "update_subject_teach_class/2 with valid data updates the subject_teach_class" do
      subject_teach_class = subject_teach_class_fixture()
      assert {:ok, subject_teach_class} = Affairs.update_subject_teach_class(subject_teach_class, @update_attrs)
      assert %SubjectTeachClass{} = subject_teach_class
      assert subject_teach_class.class_id == 43
      assert subject_teach_class.standard_id == 43
      assert subject_teach_class.subject_id == 43
      assert subject_teach_class.teacher_id == 43
    end

    test "update_subject_teach_class/2 with invalid data returns error changeset" do
      subject_teach_class = subject_teach_class_fixture()
      assert {:error, %Ecto.Changeset{}} = Affairs.update_subject_teach_class(subject_teach_class, @invalid_attrs)
      assert subject_teach_class == Affairs.get_subject_teach_class!(subject_teach_class.id)
    end

    test "delete_subject_teach_class/1 deletes the subject_teach_class" do
      subject_teach_class = subject_teach_class_fixture()
      assert {:ok, %SubjectTeachClass{}} = Affairs.delete_subject_teach_class(subject_teach_class)
      assert_raise Ecto.NoResultsError, fn -> Affairs.get_subject_teach_class!(subject_teach_class.id) end
    end

    test "change_subject_teach_class/1 returns a subject_teach_class changeset" do
      subject_teach_class = subject_teach_class_fixture()
      assert %Ecto.Changeset{} = Affairs.change_subject_teach_class(subject_teach_class)
    end
  end
end
