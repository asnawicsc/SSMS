defmodule SchoolWeb.ExamPeriodControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{end_date: ~N[2010-04-17 14:00:00.000000], exam_id: 42, start_date: ~N[2010-04-17 14:00:00.000000]}
  @update_attrs %{end_date: ~N[2011-05-18 15:01:01.000000], exam_id: 43, start_date: ~N[2011-05-18 15:01:01.000000]}
  @invalid_attrs %{end_date: nil, exam_id: nil, start_date: nil}

  def fixture(:exam_period) do
    {:ok, exam_period} = Affairs.create_exam_period(@create_attrs)
    exam_period
  end

  describe "index" do
    test "lists all examperiod", %{conn: conn} do
      conn = get conn, exam_period_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Examperiod"
    end
  end

  describe "new exam_period" do
    test "renders form", %{conn: conn} do
      conn = get conn, exam_period_path(conn, :new)
      assert html_response(conn, 200) =~ "New Exam period"
    end
  end

  describe "create exam_period" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, exam_period_path(conn, :create), exam_period: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == exam_period_path(conn, :show, id)

      conn = get conn, exam_period_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Exam period"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, exam_period_path(conn, :create), exam_period: @invalid_attrs
      assert html_response(conn, 200) =~ "New Exam period"
    end
  end

  describe "edit exam_period" do
    setup [:create_exam_period]

    test "renders form for editing chosen exam_period", %{conn: conn, exam_period: exam_period} do
      conn = get conn, exam_period_path(conn, :edit, exam_period)
      assert html_response(conn, 200) =~ "Edit Exam period"
    end
  end

  describe "update exam_period" do
    setup [:create_exam_period]

    test "redirects when data is valid", %{conn: conn, exam_period: exam_period} do
      conn = put conn, exam_period_path(conn, :update, exam_period), exam_period: @update_attrs
      assert redirected_to(conn) == exam_period_path(conn, :show, exam_period)

      conn = get conn, exam_period_path(conn, :show, exam_period)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, exam_period: exam_period} do
      conn = put conn, exam_period_path(conn, :update, exam_period), exam_period: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Exam period"
    end
  end

  describe "delete exam_period" do
    setup [:create_exam_period]

    test "deletes chosen exam_period", %{conn: conn, exam_period: exam_period} do
      conn = delete conn, exam_period_path(conn, :delete, exam_period)
      assert redirected_to(conn) == exam_period_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, exam_period_path(conn, :show, exam_period)
      end
    end
  end

  defp create_exam_period(_) do
    exam_period = fixture(:exam_period)
    {:ok, exam_period: exam_period}
  end
end
