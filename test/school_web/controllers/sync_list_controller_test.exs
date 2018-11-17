defmodule SchoolWeb.SyncListControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{executed_time: "2010-04-17 14:00:00.000000Z", period_id: 42, status: "some status"}
  @update_attrs %{executed_time: "2011-05-18 15:01:01.000000Z", period_id: 43, status: "some updated status"}
  @invalid_attrs %{executed_time: nil, period_id: nil, status: nil}

  def fixture(:sync_list) do
    {:ok, sync_list} = Affairs.create_sync_list(@create_attrs)
    sync_list
  end

  describe "index" do
    test "lists all sync_list", %{conn: conn} do
      conn = get conn, sync_list_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Sync list"
    end
  end

  describe "new sync_list" do
    test "renders form", %{conn: conn} do
      conn = get conn, sync_list_path(conn, :new)
      assert html_response(conn, 200) =~ "New Sync list"
    end
  end

  describe "create sync_list" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, sync_list_path(conn, :create), sync_list: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == sync_list_path(conn, :show, id)

      conn = get conn, sync_list_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Sync list"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, sync_list_path(conn, :create), sync_list: @invalid_attrs
      assert html_response(conn, 200) =~ "New Sync list"
    end
  end

  describe "edit sync_list" do
    setup [:create_sync_list]

    test "renders form for editing chosen sync_list", %{conn: conn, sync_list: sync_list} do
      conn = get conn, sync_list_path(conn, :edit, sync_list)
      assert html_response(conn, 200) =~ "Edit Sync list"
    end
  end

  describe "update sync_list" do
    setup [:create_sync_list]

    test "redirects when data is valid", %{conn: conn, sync_list: sync_list} do
      conn = put conn, sync_list_path(conn, :update, sync_list), sync_list: @update_attrs
      assert redirected_to(conn) == sync_list_path(conn, :show, sync_list)

      conn = get conn, sync_list_path(conn, :show, sync_list)
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, sync_list: sync_list} do
      conn = put conn, sync_list_path(conn, :update, sync_list), sync_list: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sync list"
    end
  end

  describe "delete sync_list" do
    setup [:create_sync_list]

    test "deletes chosen sync_list", %{conn: conn, sync_list: sync_list} do
      conn = delete conn, sync_list_path(conn, :delete, sync_list)
      assert redirected_to(conn) == sync_list_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, sync_list_path(conn, :show, sync_list)
      end
    end
  end

  defp create_sync_list(_) do
    sync_list = fixture(:sync_list)
    {:ok, sync_list: sync_list}
  end
end
