defmodule SchoolWeb.AttendanceControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{attendance_date: ~D[2010-04-17], class_id: 42, institution_id: 42, mark_by: "some mark_by", semester_id: 42, student_id: 42}
  @update_attrs %{attendance_date: ~D[2011-05-18], class_id: 43, institution_id: 43, mark_by: "some updated mark_by", semester_id: 43, student_id: 43}
  @invalid_attrs %{attendance_date: nil, class_id: nil, institution_id: nil, mark_by: nil, semester_id: nil, student_id: nil}

  def fixture(:attendance) do
    {:ok, attendance} = Affairs.create_attendance(@create_attrs)
    attendance
  end

  describe "index" do
    test "lists all attendance", %{conn: conn} do
      conn = get conn, attendance_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Attendance"
    end
  end

  describe "new attendance" do
    test "renders form", %{conn: conn} do
      conn = get conn, attendance_path(conn, :new)
      assert html_response(conn, 200) =~ "New Attendance"
    end
  end

  describe "create attendance" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, attendance_path(conn, :create), attendance: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == attendance_path(conn, :show, id)

      conn = get conn, attendance_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Attendance"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, attendance_path(conn, :create), attendance: @invalid_attrs
      assert html_response(conn, 200) =~ "New Attendance"
    end
  end

  describe "edit attendance" do
    setup [:create_attendance]

    test "renders form for editing chosen attendance", %{conn: conn, attendance: attendance} do
      conn = get conn, attendance_path(conn, :edit, attendance)
      assert html_response(conn, 200) =~ "Edit Attendance"
    end
  end

  describe "update attendance" do
    setup [:create_attendance]

    test "redirects when data is valid", %{conn: conn, attendance: attendance} do
      conn = put conn, attendance_path(conn, :update, attendance), attendance: @update_attrs
      assert redirected_to(conn) == attendance_path(conn, :show, attendance)

      conn = get conn, attendance_path(conn, :show, attendance)
      assert html_response(conn, 200) =~ "some updated mark_by"
    end

    test "renders errors when data is invalid", %{conn: conn, attendance: attendance} do
      conn = put conn, attendance_path(conn, :update, attendance), attendance: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Attendance"
    end
  end

  describe "delete attendance" do
    setup [:create_attendance]

    test "deletes chosen attendance", %{conn: conn, attendance: attendance} do
      conn = delete conn, attendance_path(conn, :delete, attendance)
      assert redirected_to(conn) == attendance_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, attendance_path(conn, :show, attendance)
      end
    end
  end

  defp create_attendance(_) do
    attendance = fixture(:attendance)
    {:ok, attendance: attendance}
  end
end
