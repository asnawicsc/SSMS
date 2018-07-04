defmodule SchoolWeb.StudentControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{blood_type: "some blood_type", chinese_name: "some chinese_name", country: "some country", distance: "some distance", dob: "some dob", guardian_ids: "some guardian_ids", ic: "some ic", is_oku: true, line1: "some line1", line2: "some line2", name: "some name", nationality: "some nationality", oku_cat: "some oku_cat", oku_no: "some oku_no", pass: "some pass", phone: "some phone", pob: "some pob", position_in_house: "some position_in_house", postcode: "some postcode", race: "some race", religion: "some religion", sex: "some sex", state: "some state", subject_ids: "some subject_ids", town: "some town", transport: "some transport", username: "some username"}
  @update_attrs %{blood_type: "some updated blood_type", chinese_name: "some updated chinese_name", country: "some updated country", distance: "some updated distance", dob: "some updated dob", guardian_ids: "some updated guardian_ids", ic: "some updated ic", is_oku: false, line1: "some updated line1", line2: "some updated line2", name: "some updated name", nationality: "some updated nationality", oku_cat: "some updated oku_cat", oku_no: "some updated oku_no", pass: "some updated pass", phone: "some updated phone", pob: "some updated pob", position_in_house: "some updated position_in_house", postcode: "some updated postcode", race: "some updated race", religion: "some updated religion", sex: "some updated sex", state: "some updated state", subject_ids: "some updated subject_ids", town: "some updated town", transport: "some updated transport", username: "some updated username"}
  @invalid_attrs %{blood_type: nil, chinese_name: nil, country: nil, distance: nil, dob: nil, guardian_ids: nil, ic: nil, is_oku: nil, line1: nil, line2: nil, name: nil, nationality: nil, oku_cat: nil, oku_no: nil, pass: nil, phone: nil, pob: nil, position_in_house: nil, postcode: nil, race: nil, religion: nil, sex: nil, state: nil, subject_ids: nil, town: nil, transport: nil, username: nil}

  def fixture(:student) do
    {:ok, student} = Affairs.create_student(@create_attrs)
    student
  end

  describe "index" do
    test "lists all students", %{conn: conn} do
      conn = get conn, student_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Students"
    end
  end

  describe "new student" do
    test "renders form", %{conn: conn} do
      conn = get conn, student_path(conn, :new)
      assert html_response(conn, 200) =~ "New Student"
    end
  end

  describe "create student" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, student_path(conn, :create), student: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == student_path(conn, :show, id)

      conn = get conn, student_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Student"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, student_path(conn, :create), student: @invalid_attrs
      assert html_response(conn, 200) =~ "New Student"
    end
  end

  describe "edit student" do
    setup [:create_student]

    test "renders form for editing chosen student", %{conn: conn, student: student} do
      conn = get conn, student_path(conn, :edit, student)
      assert html_response(conn, 200) =~ "Edit Student"
    end
  end

  describe "update student" do
    setup [:create_student]

    test "redirects when data is valid", %{conn: conn, student: student} do
      conn = put conn, student_path(conn, :update, student), student: @update_attrs
      assert redirected_to(conn) == student_path(conn, :show, student)

      conn = get conn, student_path(conn, :show, student)
      assert html_response(conn, 200) =~ "some updated blood_type"
    end

    test "renders errors when data is invalid", %{conn: conn, student: student} do
      conn = put conn, student_path(conn, :update, student), student: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Student"
    end
  end

  describe "delete student" do
    setup [:create_student]

    test "deletes chosen student", %{conn: conn, student: student} do
      conn = delete conn, student_path(conn, :delete, student)
      assert redirected_to(conn) == student_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, student_path(conn, :show, student)
      end
    end
  end

  defp create_student(_) do
    student = fixture(:student)
    {:ok, student: student}
  end
end
