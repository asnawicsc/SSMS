defmodule School.SchoolTest do
  use School.DataCase

  alias School.School

  describe "teachers" do
    alias School.School.Teacher

    @valid_attrs %{tccjob6: "some tccjob6", tscjob4: "some tscjob4", icno: "some icno", addr3: "some addr3", nation: "some nation", tscjob1: "some tscjob1", tccjob4: "some tccjob4", name: "some name", session: "some session", tccjob2: "some tccjob2", tccjob5: "some tccjob5", remark: "some remark", tchtype: "some tchtype", qdate: "some qdate", addr1: "some addr1", tel: "some tel", tscjob5: "some tscjob5", state: "some state", tscjob3: "some tscjob3", job: "some job", bcenrlno: 42, tscjob2: "some tscjob2", postitle: "some postitle", secondid: "some secondid", tccjob3: "some tccjob3", poscod: "some poscod", tccjob1: "some tccjob1", regdate: "some regdate", code: "some code", tscjob6: "some tscjob6", race: "some race", addr2: "some addr2", sex: "some sex", bdate: "some bdate", cname: "some cname", gid: "some gid", district: "some district", religion: "some religion", qrem: "some qrem", education: "some education"}
    @update_attrs %{tccjob6: "some updated tccjob6", tscjob4: "some updated tscjob4", icno: "some updated icno", addr3: "some updated addr3", nation: "some updated nation", tscjob1: "some updated tscjob1", tccjob4: "some updated tccjob4", name: "some updated name", session: "some updated session", tccjob2: "some updated tccjob2", tccjob5: "some updated tccjob5", remark: "some updated remark", tchtype: "some updated tchtype", qdate: "some updated qdate", addr1: "some updated addr1", tel: "some updated tel", tscjob5: "some updated tscjob5", state: "some updated state", tscjob3: "some updated tscjob3", job: "some updated job", bcenrlno: 43, tscjob2: "some updated tscjob2", postitle: "some updated postitle", secondid: "some updated secondid", tccjob3: "some updated tccjob3", poscod: "some updated poscod", tccjob1: "some updated tccjob1", regdate: "some updated regdate", code: "some updated code", tscjob6: "some updated tscjob6", race: "some updated race", addr2: "some updated addr2", sex: "some updated sex", bdate: "some updated bdate", cname: "some updated cname", gid: "some updated gid", district: "some updated district", religion: "some updated religion", qrem: "some updated qrem", education: "some updated education"}
    @invalid_attrs %{tccjob6: nil, tscjob4: nil, icno: nil, addr3: nil, nation: nil, tscjob1: nil, tccjob4: nil, name: nil, session: nil, tccjob2: nil, tccjob5: nil, remark: nil, tchtype: nil, qdate: nil, addr1: nil, tel: nil, tscjob5: nil, state: nil, tscjob3: nil, job: nil, bcenrlno: nil, tscjob2: nil, postitle: nil, secondid: nil, tccjob3: nil, poscod: nil, tccjob1: nil, regdate: nil, code: nil, tscjob6: nil, race: nil, addr2: nil, sex: nil, bdate: nil, cname: nil, gid: nil, district: nil, religion: nil, qrem: nil, education: nil}

    def teacher_fixture(attrs \\ %{}) do
      {:ok, teacher} =
        attrs
        |> Enum.into(@valid_attrs)
        |> School.create_teacher()

      teacher
    end

    test "list_teachers/0 returns all teachers" do
      teacher = teacher_fixture()
      assert School.list_teachers() == [teacher]
    end

    test "get_teacher!/1 returns the teacher with given id" do
      teacher = teacher_fixture()
      assert School.get_teacher!(teacher.id) == teacher
    end

    test "create_teacher/1 with valid data creates a teacher" do
      assert {:ok, %Teacher{} = teacher} = School.create_teacher(@valid_attrs)
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
      assert {:error, %Ecto.Changeset{}} = School.create_teacher(@invalid_attrs)
    end

    test "update_teacher/2 with valid data updates the teacher" do
      teacher = teacher_fixture()
      assert {:ok, teacher} = School.update_teacher(teacher, @update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = School.update_teacher(teacher, @invalid_attrs)
      assert teacher == School.get_teacher!(teacher.id)
    end

    test "delete_teacher/1 deletes the teacher" do
      teacher = teacher_fixture()
      assert {:ok, %Teacher{}} = School.delete_teacher(teacher)
      assert_raise Ecto.NoResultsError, fn -> School.get_teacher!(teacher.id) end
    end

    test "change_teacher/1 returns a teacher changeset" do
      teacher = teacher_fixture()
      assert %Ecto.Changeset{} = School.change_teacher(teacher)
    end
  end

  describe "uniformed_bodies" do
    alias School.School.Uniformed_Body

    @valid_attrs %{id: 42, student_name: "some student_name", unit_name: "some unit_name"}
    @update_attrs %{id: 43, student_name: "some updated student_name", unit_name: "some updated unit_name"}
    @invalid_attrs %{id: nil, student_name: nil, unit_name: nil}

    def uniformed__body_fixture(attrs \\ %{}) do
      {:ok, uniformed__body} =
        attrs
        |> Enum.into(@valid_attrs)
        |> School.create_uniformed__body()

      uniformed__body
    end

    test "list_uniformed_bodies/0 returns all uniformed_bodies" do
      uniformed__body = uniformed__body_fixture()
      assert School.list_uniformed_bodies() == [uniformed__body]
    end

    test "get_uniformed__body!/1 returns the uniformed__body with given id" do
      uniformed__body = uniformed__body_fixture()
      assert School.get_uniformed__body!(uniformed__body.id) == uniformed__body
    end

    test "create_uniformed__body/1 with valid data creates a uniformed__body" do
      assert {:ok, %Uniformed_Body{} = uniformed__body} = School.create_uniformed__body(@valid_attrs)
      assert uniformed__body.id == 42
      assert uniformed__body.student_name == "some student_name"
      assert uniformed__body.unit_name == "some unit_name"
    end

    test "create_uniformed__body/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = School.create_uniformed__body(@invalid_attrs)
    end

    test "update_uniformed__body/2 with valid data updates the uniformed__body" do
      uniformed__body = uniformed__body_fixture()
      assert {:ok, uniformed__body} = School.update_uniformed__body(uniformed__body, @update_attrs)
      assert %Uniformed_Body{} = uniformed__body
      assert uniformed__body.id == 43
      assert uniformed__body.student_name == "some updated student_name"
      assert uniformed__body.unit_name == "some updated unit_name"
    end

    test "update_uniformed__body/2 with invalid data returns error changeset" do
      uniformed__body = uniformed__body_fixture()
      assert {:error, %Ecto.Changeset{}} = School.update_uniformed__body(uniformed__body, @invalid_attrs)
      assert uniformed__body == School.get_uniformed__body!(uniformed__body.id)
    end

    test "delete_uniformed__body/1 deletes the uniformed__body" do
      uniformed__body = uniformed__body_fixture()
      assert {:ok, %Uniformed_Body{}} = School.delete_uniformed__body(uniformed__body)
      assert_raise Ecto.NoResultsError, fn -> School.get_uniformed__body!(uniformed__body.id) end
    end

    test "change_uniformed__body/1 returns a uniformed__body changeset" do
      uniformed__body = uniformed__body_fixture()
      assert %Ecto.Changeset{} = School.change_uniformed__body(uniformed__body)
    end
  end

  describe "uniformed_units" do
    alias School.School.Uniformed_uni

    @valid_attrs %{student_id: 42, student_name: "some student_name", unit_code: "some unit_code", unit_name: "some unit_name"}
    @update_attrs %{student_id: 43, student_name: "some updated student_name", unit_code: "some updated unit_code", unit_name: "some updated unit_name"}
    @invalid_attrs %{student_id: nil, student_name: nil, unit_code: nil, unit_name: nil}

    def uniformed_uni_fixture(attrs \\ %{}) do
      {:ok, uniformed_uni} =
        attrs
        |> Enum.into(@valid_attrs)
        |> School.create_uniformed_uni()

      uniformed_uni
    end

    test "list_uniformed_units/0 returns all uniformed_units" do
      uniformed_uni = uniformed_uni_fixture()
      assert School.list_uniformed_units() == [uniformed_uni]
    end

    test "get_uniformed_uni!/1 returns the uniformed_uni with given id" do
      uniformed_uni = uniformed_uni_fixture()
      assert School.get_uniformed_uni!(uniformed_uni.id) == uniformed_uni
    end

    test "create_uniformed_uni/1 with valid data creates a uniformed_uni" do
      assert {:ok, %Uniformed_uni{} = uniformed_uni} = School.create_uniformed_uni(@valid_attrs)
      assert uniformed_uni.student_id == 42
      assert uniformed_uni.student_name == "some student_name"
      assert uniformed_uni.unit_code == "some unit_code"
      assert uniformed_uni.unit_name == "some unit_name"
    end

    test "create_uniformed_uni/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = School.create_uniformed_uni(@invalid_attrs)
    end

    test "update_uniformed_uni/2 with valid data updates the uniformed_uni" do
      uniformed_uni = uniformed_uni_fixture()
      assert {:ok, uniformed_uni} = School.update_uniformed_uni(uniformed_uni, @update_attrs)
      assert %Uniformed_uni{} = uniformed_uni
      assert uniformed_uni.student_id == 43
      assert uniformed_uni.student_name == "some updated student_name"
      assert uniformed_uni.unit_code == "some updated unit_code"
      assert uniformed_uni.unit_name == "some updated unit_name"
    end

    test "update_uniformed_uni/2 with invalid data returns error changeset" do
      uniformed_uni = uniformed_uni_fixture()
      assert {:error, %Ecto.Changeset{}} = School.update_uniformed_uni(uniformed_uni, @invalid_attrs)
      assert uniformed_uni == School.get_uniformed_uni!(uniformed_uni.id)
    end

    test "delete_uniformed_uni/1 deletes the uniformed_uni" do
      uniformed_uni = uniformed_uni_fixture()
      assert {:ok, %Uniformed_uni{}} = School.delete_uniformed_uni(uniformed_uni)
      assert_raise Ecto.NoResultsError, fn -> School.get_uniformed_uni!(uniformed_uni.id) end
    end

    test "change_uniformed_uni/1 returns a uniformed_uni changeset" do
      uniformed_uni = uniformed_uni_fixture()
      assert %Ecto.Changeset{} = School.change_uniformed_uni(uniformed_uni)
    end
  end
end
