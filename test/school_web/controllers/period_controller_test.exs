defmodule SchoolWeb.PeriodControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{day: "some day", end_time: ~T[14:00:00.000000], start_time: ~T[14:00:00.000000], subject_id: 42, teacher_id: 42}
  @update_attrs %{day: "some updated day", end_time: ~T[15:01:01.000000], start_time: ~T[15:01:01.000000], subject_id: 43, teacher_id: 43}
  @invalid_attrs %{day: nil, end_time: nil, start_time: nil, subject_id: nil, teacher_id: nil}

  def fixture(:period) do
    {:ok, period} = Affairs.create_period(@create_attrs)
    period
  end

  describe "index" do
    test "lists all period", %{conn: conn} do
      conn = get conn, period_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Period"
    end
  end

  describe "new period" do
    test "renders form", %{conn: conn} do
      conn = get conn, period_path(conn, :new)
      assert html_response(conn, 200) =~ "New Period"
    end
  end

  describe "create period" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, period_path(conn, :create), period: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == period_path(conn, :show, id)

      conn = get conn, period_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Period"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, period_path(conn, :create), period: @invalid_attrs
      assert html_response(conn, 200) =~ "New Period"
    end
  end

  describe "edit period" do
    setup [:create_period]

    test "renders form for editing chosen period", %{conn: conn, period: period} do
      conn = get conn, period_path(conn, :edit, period)
      assert html_response(conn, 200) =~ "Edit Period"
    end
  end

  describe "update period" do
    setup [:create_period]

    test "redirects when data is valid", %{conn: conn, period: period} do
      conn = put conn, period_path(conn, :update, period), period: @update_attrs
      assert redirected_to(conn) == period_path(conn, :show, period)

      conn = get conn, period_path(conn, :show, period)
      assert html_response(conn, 200) =~ "some updated day"
    end

    test "renders errors when data is invalid", %{conn: conn, period: period} do
      conn = put conn, period_path(conn, :update, period), period: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Period"
    end
  end

  describe "delete period" do
    setup [:create_period]

    test "deletes chosen period", %{conn: conn, period: period} do
      conn = delete conn, period_path(conn, :delete, period)
      assert redirected_to(conn) == period_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, period_path(conn, :show, period)
      end
    end
  end

  defp create_period(_) do
    period = fixture(:period)
    {:ok, period: period}
  end
end
