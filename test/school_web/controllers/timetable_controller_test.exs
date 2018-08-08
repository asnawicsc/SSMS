defmodule SchoolWeb.TimetableControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, institution_id: 42, level_id: 42, period_id: 42, semester_id: 42}
  @update_attrs %{class_id: 43, institution_id: 43, level_id: 43, period_id: 43, semester_id: 43}
  @invalid_attrs %{class_id: nil, institution_id: nil, level_id: nil, period_id: nil, semester_id: nil}

  def fixture(:timetable) do
    {:ok, timetable} = Affairs.create_timetable(@create_attrs)
    timetable
  end

  describe "index" do
    test "lists all timetable", %{conn: conn} do
      conn = get conn, timetable_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Timetable"
    end
  end

  describe "new timetable" do
    test "renders form", %{conn: conn} do
      conn = get conn, timetable_path(conn, :new)
      assert html_response(conn, 200) =~ "New Timetable"
    end
  end

  describe "create timetable" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, timetable_path(conn, :create), timetable: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == timetable_path(conn, :show, id)

      conn = get conn, timetable_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Timetable"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, timetable_path(conn, :create), timetable: @invalid_attrs
      assert html_response(conn, 200) =~ "New Timetable"
    end
  end

  describe "edit timetable" do
    setup [:create_timetable]

    test "renders form for editing chosen timetable", %{conn: conn, timetable: timetable} do
      conn = get conn, timetable_path(conn, :edit, timetable)
      assert html_response(conn, 200) =~ "Edit Timetable"
    end
  end

  describe "update timetable" do
    setup [:create_timetable]

    test "redirects when data is valid", %{conn: conn, timetable: timetable} do
      conn = put conn, timetable_path(conn, :update, timetable), timetable: @update_attrs
      assert redirected_to(conn) == timetable_path(conn, :show, timetable)

      conn = get conn, timetable_path(conn, :show, timetable)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, timetable: timetable} do
      conn = put conn, timetable_path(conn, :update, timetable), timetable: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Timetable"
    end
  end

  describe "delete timetable" do
    setup [:create_timetable]

    test "deletes chosen timetable", %{conn: conn, timetable: timetable} do
      conn = delete conn, timetable_path(conn, :delete, timetable)
      assert redirected_to(conn) == timetable_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, timetable_path(conn, :show, timetable)
      end
    end
  end

  defp create_timetable(_) do
    timetable = fixture(:timetable)
    {:ok, timetable: timetable}
  end
end
