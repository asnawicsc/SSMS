defmodule SchoolWeb.ShiftMasterControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{day: "some day", end_time: ~T[14:00:00.000000], institution_id: 42, name: "some name", semester_id: 42, start_time: ~T[14:00:00.000000]}
  @update_attrs %{day: "some updated day", end_time: ~T[15:01:01.000000], institution_id: 43, name: "some updated name", semester_id: 43, start_time: ~T[15:01:01.000000]}
  @invalid_attrs %{day: nil, end_time: nil, institution_id: nil, name: nil, semester_id: nil, start_time: nil}

  def fixture(:shift_master) do
    {:ok, shift_master} = Affairs.create_shift_master(@create_attrs)
    shift_master
  end

  describe "index" do
    test "lists all shift_master", %{conn: conn} do
      conn = get conn, shift_master_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Shift master"
    end
  end

  describe "new shift_master" do
    test "renders form", %{conn: conn} do
      conn = get conn, shift_master_path(conn, :new)
      assert html_response(conn, 200) =~ "New Shift master"
    end
  end

  describe "create shift_master" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, shift_master_path(conn, :create), shift_master: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == shift_master_path(conn, :show, id)

      conn = get conn, shift_master_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Shift master"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, shift_master_path(conn, :create), shift_master: @invalid_attrs
      assert html_response(conn, 200) =~ "New Shift master"
    end
  end

  describe "edit shift_master" do
    setup [:create_shift_master]

    test "renders form for editing chosen shift_master", %{conn: conn, shift_master: shift_master} do
      conn = get conn, shift_master_path(conn, :edit, shift_master)
      assert html_response(conn, 200) =~ "Edit Shift master"
    end
  end

  describe "update shift_master" do
    setup [:create_shift_master]

    test "redirects when data is valid", %{conn: conn, shift_master: shift_master} do
      conn = put conn, shift_master_path(conn, :update, shift_master), shift_master: @update_attrs
      assert redirected_to(conn) == shift_master_path(conn, :show, shift_master)

      conn = get conn, shift_master_path(conn, :show, shift_master)
      assert html_response(conn, 200) =~ "some updated day"
    end

    test "renders errors when data is invalid", %{conn: conn, shift_master: shift_master} do
      conn = put conn, shift_master_path(conn, :update, shift_master), shift_master: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Shift master"
    end
  end

  describe "delete shift_master" do
    setup [:create_shift_master]

    test "deletes chosen shift_master", %{conn: conn, shift_master: shift_master} do
      conn = delete conn, shift_master_path(conn, :delete, shift_master)
      assert redirected_to(conn) == shift_master_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, shift_master_path(conn, :show, shift_master)
      end
    end
  end

  defp create_shift_master(_) do
    shift_master = fixture(:shift_master)
    {:ok, shift_master: shift_master}
  end
end
