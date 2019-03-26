defmodule SchoolWeb.TeacherAbsentControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{alasan: "some alasan", date: ~D[2010-04-17], institution_id: 42, month: "some month", remark: "some remark", semester_id: 42, teacher_id: 42}
  @update_attrs %{alasan: "some updated alasan", date: ~D[2011-05-18], institution_id: 43, month: "some updated month", remark: "some updated remark", semester_id: 43, teacher_id: 43}
  @invalid_attrs %{alasan: nil, date: nil, institution_id: nil, month: nil, remark: nil, semester_id: nil, teacher_id: nil}

  def fixture(:teacher_absent) do
    {:ok, teacher_absent} = Affairs.create_teacher_absent(@create_attrs)
    teacher_absent
  end

  describe "index" do
    test "lists all teacher_absent", %{conn: conn} do
      conn = get conn, teacher_absent_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teacher absent"
    end
  end

  describe "new teacher_absent" do
    test "renders form", %{conn: conn} do
      conn = get conn, teacher_absent_path(conn, :new)
      assert html_response(conn, 200) =~ "New Teacher absent"
    end
  end

  describe "create teacher_absent" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, teacher_absent_path(conn, :create), teacher_absent: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == teacher_absent_path(conn, :show, id)

      conn = get conn, teacher_absent_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Teacher absent"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, teacher_absent_path(conn, :create), teacher_absent: @invalid_attrs
      assert html_response(conn, 200) =~ "New Teacher absent"
    end
  end

  describe "edit teacher_absent" do
    setup [:create_teacher_absent]

    test "renders form for editing chosen teacher_absent", %{conn: conn, teacher_absent: teacher_absent} do
      conn = get conn, teacher_absent_path(conn, :edit, teacher_absent)
      assert html_response(conn, 200) =~ "Edit Teacher absent"
    end
  end

  describe "update teacher_absent" do
    setup [:create_teacher_absent]

    test "redirects when data is valid", %{conn: conn, teacher_absent: teacher_absent} do
      conn = put conn, teacher_absent_path(conn, :update, teacher_absent), teacher_absent: @update_attrs
      assert redirected_to(conn) == teacher_absent_path(conn, :show, teacher_absent)

      conn = get conn, teacher_absent_path(conn, :show, teacher_absent)
      assert html_response(conn, 200) =~ "some updated alasan"
    end

    test "renders errors when data is invalid", %{conn: conn, teacher_absent: teacher_absent} do
      conn = put conn, teacher_absent_path(conn, :update, teacher_absent), teacher_absent: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Teacher absent"
    end
  end

  describe "delete teacher_absent" do
    setup [:create_teacher_absent]

    test "deletes chosen teacher_absent", %{conn: conn, teacher_absent: teacher_absent} do
      conn = delete conn, teacher_absent_path(conn, :delete, teacher_absent)
      assert redirected_to(conn) == teacher_absent_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, teacher_absent_path(conn, :show, teacher_absent)
      end
    end
  end

  defp create_teacher_absent(_) do
    teacher_absent = fixture(:teacher_absent)
    {:ok, teacher_absent: teacher_absent}
  end
end
