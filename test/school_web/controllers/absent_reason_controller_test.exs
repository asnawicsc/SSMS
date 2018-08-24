defmodule SchoolWeb.AbsentReasonControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{code: "some code", description: "some description", type: "some type"}
  @update_attrs %{code: "some updated code", description: "some updated description", type: "some updated type"}
  @invalid_attrs %{code: nil, description: nil, type: nil}

  def fixture(:absent_reason) do
    {:ok, absent_reason} = Affairs.create_absent_reason(@create_attrs)
    absent_reason
  end

  describe "index" do
    test "lists all absent_reason", %{conn: conn} do
      conn = get conn, absent_reason_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Absent reason"
    end
  end

  describe "new absent_reason" do
    test "renders form", %{conn: conn} do
      conn = get conn, absent_reason_path(conn, :new)
      assert html_response(conn, 200) =~ "New Absent reason"
    end
  end

  describe "create absent_reason" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, absent_reason_path(conn, :create), absent_reason: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == absent_reason_path(conn, :show, id)

      conn = get conn, absent_reason_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Absent reason"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, absent_reason_path(conn, :create), absent_reason: @invalid_attrs
      assert html_response(conn, 200) =~ "New Absent reason"
    end
  end

  describe "edit absent_reason" do
    setup [:create_absent_reason]

    test "renders form for editing chosen absent_reason", %{conn: conn, absent_reason: absent_reason} do
      conn = get conn, absent_reason_path(conn, :edit, absent_reason)
      assert html_response(conn, 200) =~ "Edit Absent reason"
    end
  end

  describe "update absent_reason" do
    setup [:create_absent_reason]

    test "redirects when data is valid", %{conn: conn, absent_reason: absent_reason} do
      conn = put conn, absent_reason_path(conn, :update, absent_reason), absent_reason: @update_attrs
      assert redirected_to(conn) == absent_reason_path(conn, :show, absent_reason)

      conn = get conn, absent_reason_path(conn, :show, absent_reason)
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, absent_reason: absent_reason} do
      conn = put conn, absent_reason_path(conn, :update, absent_reason), absent_reason: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Absent reason"
    end
  end

  describe "delete absent_reason" do
    setup [:create_absent_reason]

    test "deletes chosen absent_reason", %{conn: conn, absent_reason: absent_reason} do
      conn = delete conn, absent_reason_path(conn, :delete, absent_reason)
      assert redirected_to(conn) == absent_reason_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, absent_reason_path(conn, :show, absent_reason)
      end
    end
  end

  defp create_absent_reason(_) do
    absent_reason = fixture(:absent_reason)
    {:ok, absent_reason: absent_reason}
  end
end
