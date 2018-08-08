defmodule SchoolWeb.TeacherControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{tccjob6: "some tccjob6", tscjob4: "some tscjob4", icno: "some icno", addr3: "some addr3", nation: "some nation", tscjob1: "some tscjob1", tccjob4: "some tccjob4", name: "some name", session: "some session", tccjob2: "some tccjob2", tccjob5: "some tccjob5", remark: "some remark", tchtype: "some tchtype", qdate: "some qdate", addr1: "some addr1", tel: "some tel", tscjob5: "some tscjob5", state: "some state", tscjob3: "some tscjob3", job: "some job", bcenrlno: "some bcenrlno", tscjob2: "some tscjob2", postitle: "some postitle", secondid: "some secondid", tccjob3: "some tccjob3", poscod: "some poscod", tccjob1: "some tccjob1", regdate: "some regdate", code: "some code", tscjob6: "some tscjob6", race: "some race", addr2: "some addr2", sex: "some sex", bdate: "some bdate", cname: "some cname", gid: "some gid", district: "some district", religion: "some religion", qrem: "some qrem", education: "some education"}
  @update_attrs %{tccjob6: "some updated tccjob6", tscjob4: "some updated tscjob4", icno: "some updated icno", addr3: "some updated addr3", nation: "some updated nation", tscjob1: "some updated tscjob1", tccjob4: "some updated tccjob4", name: "some updated name", session: "some updated session", tccjob2: "some updated tccjob2", tccjob5: "some updated tccjob5", remark: "some updated remark", tchtype: "some updated tchtype", qdate: "some updated qdate", addr1: "some updated addr1", tel: "some updated tel", tscjob5: "some updated tscjob5", state: "some updated state", tscjob3: "some updated tscjob3", job: "some updated job", bcenrlno: "some updated bcenrlno", tscjob2: "some updated tscjob2", postitle: "some updated postitle", secondid: "some updated secondid", tccjob3: "some updated tccjob3", poscod: "some updated poscod", tccjob1: "some updated tccjob1", regdate: "some updated regdate", code: "some updated code", tscjob6: "some updated tscjob6", race: "some updated race", addr2: "some updated addr2", sex: "some updated sex", bdate: "some updated bdate", cname: "some updated cname", gid: "some updated gid", district: "some updated district", religion: "some updated religion", qrem: "some updated qrem", education: "some updated education"}
  @invalid_attrs %{tccjob6: nil, tscjob4: nil, icno: nil, addr3: nil, nation: nil, tscjob1: nil, tccjob4: nil, name: nil, session: nil, tccjob2: nil, tccjob5: nil, remark: nil, tchtype: nil, qdate: nil, addr1: nil, tel: nil, tscjob5: nil, state: nil, tscjob3: nil, job: nil, bcenrlno: nil, tscjob2: nil, postitle: nil, secondid: nil, tccjob3: nil, poscod: nil, tccjob1: nil, regdate: nil, code: nil, tscjob6: nil, race: nil, addr2: nil, sex: nil, bdate: nil, cname: nil, gid: nil, district: nil, religion: nil, qrem: nil, education: nil}

  def fixture(:teacher) do
    {:ok, teacher} = Affairs.create_teacher(@create_attrs)
    teacher
  end

  describe "index" do
    test "lists all teacher", %{conn: conn} do
      conn = get conn, teacher_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teacher"
    end
  end

  describe "new teacher" do
    test "renders form", %{conn: conn} do
      conn = get conn, teacher_path(conn, :new)
      assert html_response(conn, 200) =~ "New Teacher"
    end
  end

  describe "create teacher" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, teacher_path(conn, :create), teacher: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == teacher_path(conn, :show, id)

      conn = get conn, teacher_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Teacher"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, teacher_path(conn, :create), teacher: @invalid_attrs
      assert html_response(conn, 200) =~ "New Teacher"
    end
  end

  describe "edit teacher" do
    setup [:create_teacher]

    test "renders form for editing chosen teacher", %{conn: conn, teacher: teacher} do
      conn = get conn, teacher_path(conn, :edit, teacher)
      assert html_response(conn, 200) =~ "Edit Teacher"
    end
  end

  describe "update teacher" do
    setup [:create_teacher]

    test "redirects when data is valid", %{conn: conn, teacher: teacher} do
      conn = put conn, teacher_path(conn, :update, teacher), teacher: @update_attrs
      assert redirected_to(conn) == teacher_path(conn, :show, teacher)

      conn = get conn, teacher_path(conn, :show, teacher)
      assert html_response(conn, 200) =~ "some updated tccjob6"
    end

    test "renders errors when data is invalid", %{conn: conn, teacher: teacher} do
      conn = put conn, teacher_path(conn, :update, teacher), teacher: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Teacher"
    end
  end

  describe "delete teacher" do
    setup [:create_teacher]

    test "deletes chosen teacher", %{conn: conn, teacher: teacher} do
      conn = delete conn, teacher_path(conn, :delete, teacher)
      assert redirected_to(conn) == teacher_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, teacher_path(conn, :show, teacher)
      end
    end
  end

  defp create_teacher(_) do
    teacher = fixture(:teacher)
    {:ok, teacher: teacher}
  end
end
