defmodule SchoolWeb.TeacherPeriodControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, day: "some day", end_time: ~T[14:00:00.000000], start_time: ~T[14:00:00.000000], subject_id: 42, teacher_id: 42}
  @update_attrs %{class_id: 43, day: "some updated day", end_time: ~T[15:01:01.000000], start_time: ~T[15:01:01.000000], subject_id: 43, teacher_id: 43}
  @invalid_attrs %{class_id: nil, day: nil, end_time: nil, start_time: nil, subject_id: nil, teacher_id: nil}

  def fixture(:teacher_period) do
    {:ok, teacher_period} = Affairs.create_teacher_period(@create_attrs)
    teacher_period
  end

  describe "index" do
    test "lists all teacher_period", %{conn: conn} do
      conn = get conn, teacher_period_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teacher period"
    end
  end

  describe "new teacher_period" do
    test "renders form", %{conn: conn} do
      conn = get conn, teacher_period_path(conn, :new)
      assert html_response(conn, 200) =~ "New Teacher period"
    end
  end

  describe "create teacher_period" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, teacher_period_path(conn, :create), teacher_period: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == teacher_period_path(conn, :show, id)

      conn = get conn, teacher_period_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Teacher period"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, teacher_period_path(conn, :create), teacher_period: @invalid_attrs
      assert html_response(conn, 200) =~ "New Teacher period"
    end
  end

  describe "edit teacher_period" do
    setup [:create_teacher_period]

    test "renders form for editing chosen teacher_period", %{conn: conn, teacher_period: teacher_period} do
      conn = get conn, teacher_period_path(conn, :edit, teacher_period)
      assert html_response(conn, 200) =~ "Edit Teacher period"
    end
  end

  describe "update teacher_period" do
    setup [:create_teacher_period]

    test "redirects when data is valid", %{conn: conn, teacher_period: teacher_period} do
      conn = put conn, teacher_period_path(conn, :update, teacher_period), teacher_period: @update_attrs
      assert redirected_to(conn) == teacher_period_path(conn, :show, teacher_period)

      conn = get conn, teacher_period_path(conn, :show, teacher_period)
      assert html_response(conn, 200) =~ "some updated day"
    end

    test "renders errors when data is invalid", %{conn: conn, teacher_period: teacher_period} do
      conn = put conn, teacher_period_path(conn, :update, teacher_period), teacher_period: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Teacher period"
    end
  end

  describe "delete teacher_period" do
    setup [:create_teacher_period]

    test "deletes chosen teacher_period", %{conn: conn, teacher_period: teacher_period} do
      conn = delete conn, teacher_period_path(conn, :delete, teacher_period)
      assert redirected_to(conn) == teacher_period_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, teacher_period_path(conn, :show, teacher_period)
      end
    end
  end

  defp create_teacher_period(_) do
    teacher_period = fixture(:teacher_period)
    {:ok, teacher_period: teacher_period}
  end
end
