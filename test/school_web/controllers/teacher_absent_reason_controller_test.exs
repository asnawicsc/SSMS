defmodule SchoolWeb.TeacherAbsentReasonControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{absent_reason_id: 42, semester_id: 42, teacher_id: 42}
  @update_attrs %{absent_reason_id: 43, semester_id: 43, teacher_id: 43}
  @invalid_attrs %{absent_reason_id: nil, semester_id: nil, teacher_id: nil}

  def fixture(:teacher_absent_reason) do
    {:ok, teacher_absent_reason} = Affairs.create_teacher_absent_reason(@create_attrs)
    teacher_absent_reason
  end

  describe "index" do
    test "lists all teacher_absent_reason", %{conn: conn} do
      conn = get conn, teacher_absent_reason_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teacher absent reason"
    end
  end

  describe "new teacher_absent_reason" do
    test "renders form", %{conn: conn} do
      conn = get conn, teacher_absent_reason_path(conn, :new)
      assert html_response(conn, 200) =~ "New Teacher absent reason"
    end
  end

  describe "create teacher_absent_reason" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, teacher_absent_reason_path(conn, :create), teacher_absent_reason: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == teacher_absent_reason_path(conn, :show, id)

      conn = get conn, teacher_absent_reason_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Teacher absent reason"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, teacher_absent_reason_path(conn, :create), teacher_absent_reason: @invalid_attrs
      assert html_response(conn, 200) =~ "New Teacher absent reason"
    end
  end

  describe "edit teacher_absent_reason" do
    setup [:create_teacher_absent_reason]

    test "renders form for editing chosen teacher_absent_reason", %{conn: conn, teacher_absent_reason: teacher_absent_reason} do
      conn = get conn, teacher_absent_reason_path(conn, :edit, teacher_absent_reason)
      assert html_response(conn, 200) =~ "Edit Teacher absent reason"
    end
  end

  describe "update teacher_absent_reason" do
    setup [:create_teacher_absent_reason]

    test "redirects when data is valid", %{conn: conn, teacher_absent_reason: teacher_absent_reason} do
      conn = put conn, teacher_absent_reason_path(conn, :update, teacher_absent_reason), teacher_absent_reason: @update_attrs
      assert redirected_to(conn) == teacher_absent_reason_path(conn, :show, teacher_absent_reason)

      conn = get conn, teacher_absent_reason_path(conn, :show, teacher_absent_reason)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, teacher_absent_reason: teacher_absent_reason} do
      conn = put conn, teacher_absent_reason_path(conn, :update, teacher_absent_reason), teacher_absent_reason: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Teacher absent reason"
    end
  end

  describe "delete teacher_absent_reason" do
    setup [:create_teacher_absent_reason]

    test "deletes chosen teacher_absent_reason", %{conn: conn, teacher_absent_reason: teacher_absent_reason} do
      conn = delete conn, teacher_absent_reason_path(conn, :delete, teacher_absent_reason)
      assert redirected_to(conn) == teacher_absent_reason_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, teacher_absent_reason_path(conn, :show, teacher_absent_reason)
      end
    end
  end

  defp create_teacher_absent_reason(_) do
    teacher_absent_reason = fixture(:teacher_absent_reason)
    {:ok, teacher_absent_reason: teacher_absent_reason}
  end
end
