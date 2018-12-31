defmodule SchoolWeb.TeacherAttendanceControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{institution_id: 42, semester_id: 42, teacher_id: 42, time_id: "some time_id", time_out: "some time_out"}
  @update_attrs %{institution_id: 43, semester_id: 43, teacher_id: 43, time_id: "some updated time_id", time_out: "some updated time_out"}
  @invalid_attrs %{institution_id: nil, semester_id: nil, teacher_id: nil, time_id: nil, time_out: nil}

  def fixture(:teacher_attendance) do
    {:ok, teacher_attendance} = Affairs.create_teacher_attendance(@create_attrs)
    teacher_attendance
  end

  describe "index" do
    test "lists all teacher_attendance", %{conn: conn} do
      conn = get conn, teacher_attendance_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teacher attendance"
    end
  end

  describe "new teacher_attendance" do
    test "renders form", %{conn: conn} do
      conn = get conn, teacher_attendance_path(conn, :new)
      assert html_response(conn, 200) =~ "New Teacher attendance"
    end
  end

  describe "create teacher_attendance" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, teacher_attendance_path(conn, :create), teacher_attendance: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == teacher_attendance_path(conn, :show, id)

      conn = get conn, teacher_attendance_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Teacher attendance"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, teacher_attendance_path(conn, :create), teacher_attendance: @invalid_attrs
      assert html_response(conn, 200) =~ "New Teacher attendance"
    end
  end

  describe "edit teacher_attendance" do
    setup [:create_teacher_attendance]

    test "renders form for editing chosen teacher_attendance", %{conn: conn, teacher_attendance: teacher_attendance} do
      conn = get conn, teacher_attendance_path(conn, :edit, teacher_attendance)
      assert html_response(conn, 200) =~ "Edit Teacher attendance"
    end
  end

  describe "update teacher_attendance" do
    setup [:create_teacher_attendance]

    test "redirects when data is valid", %{conn: conn, teacher_attendance: teacher_attendance} do
      conn = put conn, teacher_attendance_path(conn, :update, teacher_attendance), teacher_attendance: @update_attrs
      assert redirected_to(conn) == teacher_attendance_path(conn, :show, teacher_attendance)

      conn = get conn, teacher_attendance_path(conn, :show, teacher_attendance)
      assert html_response(conn, 200) =~ "some updated time_id"
    end

    test "renders errors when data is invalid", %{conn: conn, teacher_attendance: teacher_attendance} do
      conn = put conn, teacher_attendance_path(conn, :update, teacher_attendance), teacher_attendance: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Teacher attendance"
    end
  end

  describe "delete teacher_attendance" do
    setup [:create_teacher_attendance]

    test "deletes chosen teacher_attendance", %{conn: conn, teacher_attendance: teacher_attendance} do
      conn = delete conn, teacher_attendance_path(conn, :delete, teacher_attendance)
      assert redirected_to(conn) == teacher_attendance_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, teacher_attendance_path(conn, :show, teacher_attendance)
      end
    end
  end

  defp create_teacher_attendance(_) do
    teacher_attendance = fixture(:teacher_attendance)
    {:ok, teacher_attendance: teacher_attendance}
  end
end
