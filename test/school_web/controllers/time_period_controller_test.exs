defmodule SchoolWeb.TimePeriodControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{time_end: ~T[14:00:00.000000], time_start: ~T[14:00:00.000000]}
  @update_attrs %{time_end: ~T[15:01:01.000000], time_start: ~T[15:01:01.000000]}
  @invalid_attrs %{time_end: nil, time_start: nil}

  def fixture(:time_period) do
    {:ok, time_period} = Affairs.create_time_period(@create_attrs)
    time_period
  end

  describe "index" do
    test "lists all time_period", %{conn: conn} do
      conn = get conn, time_period_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Time period"
    end
  end

  describe "new time_period" do
    test "renders form", %{conn: conn} do
      conn = get conn, time_period_path(conn, :new)
      assert html_response(conn, 200) =~ "New Time period"
    end
  end

  describe "create time_period" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, time_period_path(conn, :create), time_period: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == time_period_path(conn, :show, id)

      conn = get conn, time_period_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Time period"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, time_period_path(conn, :create), time_period: @invalid_attrs
      assert html_response(conn, 200) =~ "New Time period"
    end
  end

  describe "edit time_period" do
    setup [:create_time_period]

    test "renders form for editing chosen time_period", %{conn: conn, time_period: time_period} do
      conn = get conn, time_period_path(conn, :edit, time_period)
      assert html_response(conn, 200) =~ "Edit Time period"
    end
  end

  describe "update time_period" do
    setup [:create_time_period]

    test "redirects when data is valid", %{conn: conn, time_period: time_period} do
      conn = put conn, time_period_path(conn, :update, time_period), time_period: @update_attrs
      assert redirected_to(conn) == time_period_path(conn, :show, time_period)

      conn = get conn, time_period_path(conn, :show, time_period)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, time_period: time_period} do
      conn = put conn, time_period_path(conn, :update, time_period), time_period: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Time period"
    end
  end

  describe "delete time_period" do
    setup [:create_time_period]

    test "deletes chosen time_period", %{conn: conn, time_period: time_period} do
      conn = delete conn, time_period_path(conn, :delete, time_period)
      assert redirected_to(conn) == time_period_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, time_period_path(conn, :show, time_period)
      end
    end
  end

  defp create_time_period(_) do
    time_period = fixture(:time_period)
    {:ok, time_period: time_period}
  end
end
