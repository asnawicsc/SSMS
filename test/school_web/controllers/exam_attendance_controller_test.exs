defmodule SchoolWeb.ExamAttendanceControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, exam_id: 42, exam_master_id: 42, institution_id: 42, semester_id: 42, student_id: 42, subject_id: 42}
  @update_attrs %{class_id: 43, exam_id: 43, exam_master_id: 43, institution_id: 43, semester_id: 43, student_id: 43, subject_id: 43}
  @invalid_attrs %{class_id: nil, exam_id: nil, exam_master_id: nil, institution_id: nil, semester_id: nil, student_id: nil, subject_id: nil}

  def fixture(:exam_attendance) do
    {:ok, exam_attendance} = Affairs.create_exam_attendance(@create_attrs)
    exam_attendance
  end

  describe "index" do
    test "lists all exam_attendance", %{conn: conn} do
      conn = get conn, exam_attendance_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Exam attendance"
    end
  end

  describe "new exam_attendance" do
    test "renders form", %{conn: conn} do
      conn = get conn, exam_attendance_path(conn, :new)
      assert html_response(conn, 200) =~ "New Exam attendance"
    end
  end

  describe "create exam_attendance" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, exam_attendance_path(conn, :create), exam_attendance: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == exam_attendance_path(conn, :show, id)

      conn = get conn, exam_attendance_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Exam attendance"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, exam_attendance_path(conn, :create), exam_attendance: @invalid_attrs
      assert html_response(conn, 200) =~ "New Exam attendance"
    end
  end

  describe "edit exam_attendance" do
    setup [:create_exam_attendance]

    test "renders form for editing chosen exam_attendance", %{conn: conn, exam_attendance: exam_attendance} do
      conn = get conn, exam_attendance_path(conn, :edit, exam_attendance)
      assert html_response(conn, 200) =~ "Edit Exam attendance"
    end
  end

  describe "update exam_attendance" do
    setup [:create_exam_attendance]

    test "redirects when data is valid", %{conn: conn, exam_attendance: exam_attendance} do
      conn = put conn, exam_attendance_path(conn, :update, exam_attendance), exam_attendance: @update_attrs
      assert redirected_to(conn) == exam_attendance_path(conn, :show, exam_attendance)

      conn = get conn, exam_attendance_path(conn, :show, exam_attendance)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, exam_attendance: exam_attendance} do
      conn = put conn, exam_attendance_path(conn, :update, exam_attendance), exam_attendance: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Exam attendance"
    end
  end

  describe "delete exam_attendance" do
    setup [:create_exam_attendance]

    test "deletes chosen exam_attendance", %{conn: conn, exam_attendance: exam_attendance} do
      conn = delete conn, exam_attendance_path(conn, :delete, exam_attendance)
      assert redirected_to(conn) == exam_attendance_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, exam_attendance_path(conn, :show, exam_attendance)
      end
    end
  end

  defp create_exam_attendance(_) do
    exam_attendance = fixture(:exam_attendance)
    {:ok, exam_attendance: exam_attendance}
  end
end
