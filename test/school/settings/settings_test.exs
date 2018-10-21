defmodule School.SettingsTest do
  use School.DataCase

  alias School.Settings

  describe "parameters" do
    alias School.Settings.Parameter

    @valid_attrs %{blood_type: "some blood_type", career: "some career", nationality: "some nationality", oku: "some oku", race: "some race", religion: "some religion", sickness: "some sickness", transport: "some transport"}
    @update_attrs %{blood_type: "some updated blood_type", career: "some updated career", nationality: "some updated nationality", oku: "some updated oku", race: "some updated race", religion: "some updated religion", sickness: "some updated sickness", transport: "some updated transport"}
    @invalid_attrs %{blood_type: nil, career: nil, nationality: nil, oku: nil, race: nil, religion: nil, sickness: nil, transport: nil}

    def parameter_fixture(attrs \\ %{}) do
      {:ok, parameter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_parameter()

      parameter
    end

    test "list_parameters/0 returns all parameters" do
      parameter = parameter_fixture()
      assert Settings.list_parameters() == [parameter]
    end

    test "get_parameter!/1 returns the parameter with given id" do
      parameter = parameter_fixture()
      assert Settings.get_parameter!(parameter.id) == parameter
    end

    test "create_parameter/1 with valid data creates a parameter" do
      assert {:ok, %Parameter{} = parameter} = Settings.create_parameter(@valid_attrs)
      assert parameter.blood_type == "some blood_type"
      assert parameter.career == "some career"
      assert parameter.nationality == "some nationality"
      assert parameter.oku == "some oku"
      assert parameter.race == "some race"
      assert parameter.religion == "some religion"
      assert parameter.sickness == "some sickness"
      assert parameter.transport == "some transport"
    end

    test "create_parameter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_parameter(@invalid_attrs)
    end

    test "update_parameter/2 with valid data updates the parameter" do
      parameter = parameter_fixture()
      assert {:ok, parameter} = Settings.update_parameter(parameter, @update_attrs)
      assert %Parameter{} = parameter
      assert parameter.blood_type == "some updated blood_type"
      assert parameter.career == "some updated career"
      assert parameter.nationality == "some updated nationality"
      assert parameter.oku == "some updated oku"
      assert parameter.race == "some updated race"
      assert parameter.religion == "some updated religion"
      assert parameter.sickness == "some updated sickness"
      assert parameter.transport == "some updated transport"
    end

    test "update_parameter/2 with invalid data returns error changeset" do
      parameter = parameter_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_parameter(parameter, @invalid_attrs)
      assert parameter == Settings.get_parameter!(parameter.id)
    end

    test "delete_parameter/1 deletes the parameter" do
      parameter = parameter_fixture()
      assert {:ok, %Parameter{}} = Settings.delete_parameter(parameter)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_parameter!(parameter.id) end
    end

    test "change_parameter/1 returns a parameter changeset" do
      parameter = parameter_fixture()
      assert %Ecto.Changeset{} = Settings.change_parameter(parameter)
    end
  end

  describe "schools" do
    alias School.Settings.School

    @valid_attrs %{countryphone: "some countryphone", email: "some email", email2: "some email2", fax: "some fax", fax2: "some fax2", line1: "some line1", line2: "some line2", logo_bin: "some logo_bin", logo_filename: "some logo_filename", name: "some name", phone2: "some phone2", postcode: "some postcode", state: "some state", town: "some town"}
    @update_attrs %{countryphone: "some updated countryphone", email: "some updated email", email2: "some updated email2", fax: "some updated fax", fax2: "some updated fax2", line1: "some updated line1", line2: "some updated line2", logo_bin: "some updated logo_bin", logo_filename: "some updated logo_filename", name: "some updated name", phone2: "some updated phone2", postcode: "some updated postcode", state: "some updated state", town: "some updated town"}
    @invalid_attrs %{countryphone: nil, email: nil, email2: nil, fax: nil, fax2: nil, line1: nil, line2: nil, logo_bin: nil, logo_filename: nil, name: nil, phone2: nil, postcode: nil, state: nil, town: nil}

    def school_fixture(attrs \\ %{}) do
      {:ok, school} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_school()

      school
    end

    test "list_schools/0 returns all schools" do
      school = school_fixture()
      assert Settings.list_schools() == [school]
    end

    test "get_school!/1 returns the school with given id" do
      school = school_fixture()
      assert Settings.get_school!(school.id) == school
    end

    test "create_school/1 with valid data creates a school" do
      assert {:ok, %School{} = school} = Settings.create_school(@valid_attrs)
      assert school.countryphone == "some countryphone"
      assert school.email == "some email"
      assert school.email2 == "some email2"
      assert school.fax == "some fax"
      assert school.fax2 == "some fax2"
      assert school.line1 == "some line1"
      assert school.line2 == "some line2"
      assert school.logo_bin == "some logo_bin"
      assert school.logo_filename == "some logo_filename"
      assert school.name == "some name"
      assert school.phone2 == "some phone2"
      assert school.postcode == "some postcode"
      assert school.state == "some state"
      assert school.town == "some town"
    end

    test "create_school/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_school(@invalid_attrs)
    end

    test "update_school/2 with valid data updates the school" do
      school = school_fixture()
      assert {:ok, school} = Settings.update_school(school, @update_attrs)
      assert %School{} = school
      assert school.countryphone == "some updated countryphone"
      assert school.email == "some updated email"
      assert school.email2 == "some updated email2"
      assert school.fax == "some updated fax"
      assert school.fax2 == "some updated fax2"
      assert school.line1 == "some updated line1"
      assert school.line2 == "some updated line2"
      assert school.logo_bin == "some updated logo_bin"
      assert school.logo_filename == "some updated logo_filename"
      assert school.name == "some updated name"
      assert school.phone2 == "some updated phone2"
      assert school.postcode == "some updated postcode"
      assert school.state == "some updated state"
      assert school.town == "some updated town"
    end

    test "update_school/2 with invalid data returns error changeset" do
      school = school_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_school(school, @invalid_attrs)
      assert school == Settings.get_school!(school.id)
    end

    test "delete_school/1 deletes the school" do
      school = school_fixture()
      assert {:ok, %School{}} = Settings.delete_school(school)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_school!(school.id) end
    end

    test "change_school/1 returns a school changeset" do
      school = school_fixture()
      assert %Ecto.Changeset{} = Settings.change_school(school)
    end
  end

  describe "institutions" do
    alias School.Settings.Institution

    @valid_attrs %{country: "some country", email: "some email", email2: "some email2", fax: "some fax", line1: "some line1", line2: "some line2", logo_bin: "some logo_bin", logo_filename: "some logo_filename", name: "some name", phone: "some phone", phone2: "some phone2", postcode: "some postcode", state: "some state", town: "some town"}
    @update_attrs %{country: "some updated country", email: "some updated email", email2: "some updated email2", fax: "some updated fax", line1: "some updated line1", line2: "some updated line2", logo_bin: "some updated logo_bin", logo_filename: "some updated logo_filename", name: "some updated name", phone: "some updated phone", phone2: "some updated phone2", postcode: "some updated postcode", state: "some updated state", town: "some updated town"}
    @invalid_attrs %{country: nil, email: nil, email2: nil, fax: nil, line1: nil, line2: nil, logo_bin: nil, logo_filename: nil, name: nil, phone: nil, phone2: nil, postcode: nil, state: nil, town: nil}

    def institution_fixture(attrs \\ %{}) do
      {:ok, institution} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_institution()

      institution
    end

    test "list_institutions/0 returns all institutions" do
      institution = institution_fixture()
      assert Settings.list_institutions() == [institution]
    end

    test "get_institution!/1 returns the institution with given id" do
      institution = institution_fixture()
      assert Settings.get_institution!(institution.id) == institution
    end

    test "create_institution/1 with valid data creates a institution" do
      assert {:ok, %Institution{} = institution} = Settings.create_institution(@valid_attrs)
      assert institution.country == "some country"
      assert institution.email == "some email"
      assert institution.email2 == "some email2"
      assert institution.fax == "some fax"
      assert institution.line1 == "some line1"
      assert institution.line2 == "some line2"
      assert institution.logo_bin == "some logo_bin"
      assert institution.logo_filename == "some logo_filename"
      assert institution.name == "some name"
      assert institution.phone == "some phone"
      assert institution.phone2 == "some phone2"
      assert institution.postcode == "some postcode"
      assert institution.state == "some state"
      assert institution.town == "some town"
    end

    test "create_institution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_institution(@invalid_attrs)
    end

    test "update_institution/2 with valid data updates the institution" do
      institution = institution_fixture()
      assert {:ok, institution} = Settings.update_institution(institution, @update_attrs)
      assert %Institution{} = institution
      assert institution.country == "some updated country"
      assert institution.email == "some updated email"
      assert institution.email2 == "some updated email2"
      assert institution.fax == "some updated fax"
      assert institution.line1 == "some updated line1"
      assert institution.line2 == "some updated line2"
      assert institution.logo_bin == "some updated logo_bin"
      assert institution.logo_filename == "some updated logo_filename"
      assert institution.name == "some updated name"
      assert institution.phone == "some updated phone"
      assert institution.phone2 == "some updated phone2"
      assert institution.postcode == "some updated postcode"
      assert institution.state == "some updated state"
      assert institution.town == "some updated town"
    end

    test "update_institution/2 with invalid data returns error changeset" do
      institution = institution_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_institution(institution, @invalid_attrs)
      assert institution == Settings.get_institution!(institution.id)
    end

    test "delete_institution/1 deletes the institution" do
      institution = institution_fixture()
      assert {:ok, %Institution{}} = Settings.delete_institution(institution)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_institution!(institution.id) end
    end

    test "change_institution/1 returns a institution changeset" do
      institution = institution_fixture()
      assert %Ecto.Changeset{} = Settings.change_institution(institution)
    end
  end

  describe "users" do
    alias School.Settings.User

    @valid_attrs %{crypted_password: "some crypted_password", institution_id: 42, name: "some name", password: "some password", role: "some role"}
    @update_attrs %{crypted_password: "some updated crypted_password", institution_id: 43, name: "some updated name", password: "some updated password", role: "some updated role"}
    @invalid_attrs %{crypted_password: nil, institution_id: nil, name: nil, password: nil, role: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Settings.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Settings.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Settings.create_user(@valid_attrs)
      assert user.crypted_password == "some crypted_password"
      assert user.institution_id == 42
      assert user.name == "some name"
      assert user.password == "some password"
      assert user.role == "some role"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Settings.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.crypted_password == "some updated crypted_password"
      assert user.institution_id == 43
      assert user.name == "some updated name"
      assert user.password == "some updated password"
      assert user.role == "some updated role"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_user(user, @invalid_attrs)
      assert user == Settings.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Settings.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Settings.change_user(user)
    end
  end

  describe "labels" do
    alias School.Settings.Label

    @valid_attrs %{bm: "some bm", cn: "some cn", en: "some en", name: "some name"}
    @update_attrs %{bm: "some updated bm", cn: "some updated cn", en: "some updated en", name: "some updated name"}
    @invalid_attrs %{bm: nil, cn: nil, en: nil, name: nil}

    def label_fixture(attrs \\ %{}) do
      {:ok, label} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_label()

      label
    end

    test "list_labels/0 returns all labels" do
      label = label_fixture()
      assert Settings.list_labels() == [label]
    end

    test "get_label!/1 returns the label with given id" do
      label = label_fixture()
      assert Settings.get_label!(label.id) == label
    end

    test "create_label/1 with valid data creates a label" do
      assert {:ok, %Label{} = label} = Settings.create_label(@valid_attrs)
      assert label.bm == "some bm"
      assert label.cn == "some cn"
      assert label.en == "some en"
      assert label.name == "some name"
    end

    test "create_label/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_label(@invalid_attrs)
    end

    test "update_label/2 with valid data updates the label" do
      label = label_fixture()
      assert {:ok, label} = Settings.update_label(label, @update_attrs)
      assert %Label{} = label
      assert label.bm == "some updated bm"
      assert label.cn == "some updated cn"
      assert label.en == "some updated en"
      assert label.name == "some updated name"
    end

    test "update_label/2 with invalid data returns error changeset" do
      label = label_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_label(label, @invalid_attrs)
      assert label == Settings.get_label!(label.id)
    end

    test "delete_label/1 deletes the label" do
      label = label_fixture()
      assert {:ok, %Label{}} = Settings.delete_label(label)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_label!(label.id) end
    end

    test "change_label/1 returns a label changeset" do
      label = label_fixture()
      assert %Ecto.Changeset{} = Settings.change_label(label)
    end
  end

  describe "teachers" do
    alias School.Settings.Teacher

    @valid_attrs %{tccjob6: "some tccjob6", tscjob4: "some tscjob4", icno: "some icno", addr3: "some addr3", nation: "some nation", tscjob1: "some tscjob1", tccjob4: "some tccjob4", name: "some name", session: "some session", tccjob2: "some tccjob2", tccjob5: "some tccjob5", remark: "some remark", tchtype: "some tchtype", qdate: "some qdate", addr1: "some addr1", tel: "some tel", tscjob5: "some tscjob5", state: "some state", tscjob3: "some tscjob3", job: "some job", bcenrlno: 42, tscjob2: "some tscjob2", postitle: "some postitle", secondid: "some secondid", tccjob3: "some tccjob3", poscod: "some poscod", tccjob1: "some tccjob1", regdate: "some regdate", code: "some code", tscjob6: "some tscjob6", race: "some race", addr2: "some addr2", sex: "some sex", bdate: "some bdate", cname: "some cname", gid: "some gid", district: "some district", religion: "some religion", qrem: "some qrem", education: "some education"}
    @update_attrs %{tccjob6: "some updated tccjob6", tscjob4: "some updated tscjob4", icno: "some updated icno", addr3: "some updated addr3", nation: "some updated nation", tscjob1: "some updated tscjob1", tccjob4: "some updated tccjob4", name: "some updated name", session: "some updated session", tccjob2: "some updated tccjob2", tccjob5: "some updated tccjob5", remark: "some updated remark", tchtype: "some updated tchtype", qdate: "some updated qdate", addr1: "some updated addr1", tel: "some updated tel", tscjob5: "some updated tscjob5", state: "some updated state", tscjob3: "some updated tscjob3", job: "some updated job", bcenrlno: 43, tscjob2: "some updated tscjob2", postitle: "some updated postitle", secondid: "some updated secondid", tccjob3: "some updated tccjob3", poscod: "some updated poscod", tccjob1: "some updated tccjob1", regdate: "some updated regdate", code: "some updated code", tscjob6: "some updated tscjob6", race: "some updated race", addr2: "some updated addr2", sex: "some updated sex", bdate: "some updated bdate", cname: "some updated cname", gid: "some updated gid", district: "some updated district", religion: "some updated religion", qrem: "some updated qrem", education: "some updated education"}
    @invalid_attrs %{tccjob6: nil, tscjob4: nil, icno: nil, addr3: nil, nation: nil, tscjob1: nil, tccjob4: nil, name: nil, session: nil, tccjob2: nil, tccjob5: nil, remark: nil, tchtype: nil, qdate: nil, addr1: nil, tel: nil, tscjob5: nil, state: nil, tscjob3: nil, job: nil, bcenrlno: nil, tscjob2: nil, postitle: nil, secondid: nil, tccjob3: nil, poscod: nil, tccjob1: nil, regdate: nil, code: nil, tscjob6: nil, race: nil, addr2: nil, sex: nil, bdate: nil, cname: nil, gid: nil, district: nil, religion: nil, qrem: nil, education: nil}

    def teacher_fixture(attrs \\ %{}) do
      {:ok, teacher} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_teacher()

      teacher
    end

    test "list_teachers/0 returns all teachers" do
      teacher = teacher_fixture()
      assert Settings.list_teachers() == [teacher]
    end

    test "get_teacher!/1 returns the teacher with given id" do
      teacher = teacher_fixture()
      assert Settings.get_teacher!(teacher.id) == teacher
    end

    test "create_teacher/1 with valid data creates a teacher" do
      assert {:ok, %Teacher{} = teacher} = Settings.create_teacher(@valid_attrs)
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
      assert teacher.bcenrlno == 42
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
      assert {:error, %Ecto.Changeset{}} = Settings.create_teacher(@invalid_attrs)
    end

    test "update_teacher/2 with valid data updates the teacher" do
      teacher = teacher_fixture()
      assert {:ok, teacher} = Settings.update_teacher(teacher, @update_attrs)
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
      assert teacher.bcenrlno == 43
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
      assert {:error, %Ecto.Changeset{}} = Settings.update_teacher(teacher, @invalid_attrs)
      assert teacher == Settings.get_teacher!(teacher.id)
    end

    test "delete_teacher/1 deletes the teacher" do
      teacher = teacher_fixture()
      assert {:ok, %Teacher{}} = Settings.delete_teacher(teacher)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_teacher!(teacher.id) end
    end

    test "change_teacher/1 returns a teacher changeset" do
      teacher = teacher_fixture()
      assert %Ecto.Changeset{} = Settings.change_teacher(teacher)
    end
  end

  describe "subjects" do
    alias School.Settings.TeSubject

    @valid_attrs %{cdesc: "some cdesc", code: "some code", description: "some description", sysdef: 42}
    @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description", sysdef: 43}
    @invalid_attrs %{cdesc: nil, code: nil, description: nil, sysdef: nil}

    def te_subject_fixture(attrs \\ %{}) do
      {:ok, te_subject} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_te_subject()

      te_subject
    end

    test "list_subjects/0 returns all subjects" do
      te_subject = te_subject_fixture()
      assert Settings.list_subjects() == [te_subject]
    end

    test "get_te_subject!/1 returns the te_subject with given id" do
      te_subject = te_subject_fixture()
      assert Settings.get_te_subject!(te_subject.id) == te_subject
    end

    test "create_te_subject/1 with valid data creates a te_subject" do
      assert {:ok, %TeSubject{} = te_subject} = Settings.create_te_subject(@valid_attrs)
      assert te_subject.cdesc == "some cdesc"
      assert te_subject.code == "some code"
      assert te_subject.description == "some description"
      assert te_subject.sysdef == 42
    end

    test "create_te_subject/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_te_subject(@invalid_attrs)
    end

    test "update_te_subject/2 with valid data updates the te_subject" do
      te_subject = te_subject_fixture()
      assert {:ok, te_subject} = Settings.update_te_subject(te_subject, @update_attrs)
      assert %TeSubject{} = te_subject
      assert te_subject.cdesc == "some updated cdesc"
      assert te_subject.code == "some updated code"
      assert te_subject.description == "some updated description"
      assert te_subject.sysdef == 43
    end

    test "update_te_subject/2 with invalid data returns error changeset" do
      te_subject = te_subject_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_te_subject(te_subject, @invalid_attrs)
      assert te_subject == Settings.get_te_subject!(te_subject.id)
    end

    test "delete_te_subject/1 deletes the te_subject" do
      te_subject = te_subject_fixture()
      assert {:ok, %TeSubject{}} = Settings.delete_te_subject(te_subject)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_te_subject!(te_subject.id) end
    end

    test "change_te_subject/1 returns a te_subject changeset" do
      te_subject = te_subject_fixture()
      assert %Ecto.Changeset{} = Settings.change_te_subject(te_subject)
    end
  end

  describe "user_access" do
    alias School.Settings.UserAccess

    @valid_attrs %{institution_id: 42, user_id: 42}
    @update_attrs %{institution_id: 43, user_id: 43}
    @invalid_attrs %{institution_id: nil, user_id: nil}

    def user_access_fixture(attrs \\ %{}) do
      {:ok, user_access} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_user_access()

      user_access
    end

    test "list_user_access/0 returns all user_access" do
      user_access = user_access_fixture()
      assert Settings.list_user_access() == [user_access]
    end

    test "get_user_access!/1 returns the user_access with given id" do
      user_access = user_access_fixture()
      assert Settings.get_user_access!(user_access.id) == user_access
    end

    test "create_user_access/1 with valid data creates a user_access" do
      assert {:ok, %UserAccess{} = user_access} = Settings.create_user_access(@valid_attrs)
      assert user_access.institution_id == 42
      assert user_access.user_id == 42
    end

    test "create_user_access/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_user_access(@invalid_attrs)
    end

    test "update_user_access/2 with valid data updates the user_access" do
      user_access = user_access_fixture()
      assert {:ok, user_access} = Settings.update_user_access(user_access, @update_attrs)
      assert %UserAccess{} = user_access
      assert user_access.institution_id == 43
      assert user_access.user_id == 43
    end

    test "update_user_access/2 with invalid data returns error changeset" do
      user_access = user_access_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_user_access(user_access, @invalid_attrs)
      assert user_access == Settings.get_user_access!(user_access.id)
    end

    test "delete_user_access/1 deletes the user_access" do
      user_access = user_access_fixture()
      assert {:ok, %UserAccess{}} = Settings.delete_user_access(user_access)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_user_access!(user_access.id) end
    end

    test "change_user_access/1 returns a user_access changeset" do
      user_access = user_access_fixture()
      assert %Ecto.Changeset{} = Settings.change_user_access(user_access)
    end
  end

  describe "role" do
    alias School.Settings.Role

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_role()

      role
    end

    test "list_role/0 returns all role" do
      role = role_fixture()
      assert Settings.list_role() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Settings.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Settings.create_role(@valid_attrs)
      assert role.name == "some name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, role} = Settings.update_role(role, @update_attrs)
      assert %Role{} = role
      assert role.name == "some updated name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_role(role, @invalid_attrs)
      assert role == Settings.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Settings.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Settings.change_role(role)
    end
  end
end
