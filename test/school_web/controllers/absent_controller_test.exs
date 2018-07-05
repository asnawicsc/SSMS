defmodule SchoolWeb.AbsentControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{absent_date: ~D[2010-04-17], reason: "some reason", student_id: 42}
  @update_attrs %{absent_date: ~D[2011-05-18], reason: "some updated reason", student_id: 43}
  @invalid_attrs %{absent_date: nil, reason: nil, student_id: nil}

  def fixture(:absent) do
    {:ok, absent} = Affairs.create_absent(@create_attrs)
    absent
  end

  describe "index" do
    test "lists all absent", %{conn: conn} do
      conn = get conn, absent_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Absent"
    end
  end

  describe "new absent" do
    test "renders form", %{conn: conn} do
      conn = get conn, absent_path(conn, :new)
      assert html_response(conn, 200) =~ "New Absent"
    end
  end

  describe "create absent" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, absent_path(conn, :create), absent: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == absent_path(conn, :show, id)

      conn = get conn, absent_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Absent"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, absent_path(conn, :create), absent: @invalid_attrs
      assert html_response(conn, 200) =~ "New Absent"
    end
  end

  describe "edit absent" do
    setup [:create_absent]

    test "renders form for editing chosen absent", %{conn: conn, absent: absent} do
      conn = get conn, absent_path(conn, :edit, absent)
      assert html_response(conn, 200) =~ "Edit Absent"
    end
  end

  describe "update absent" do
    setup [:create_absent]

    test "redirects when data is valid", %{conn: conn, absent: absent} do
      conn = put conn, absent_path(conn, :update, absent), absent: @update_attrs
      assert redirected_to(conn) == absent_path(conn, :show, absent)

      conn = get conn, absent_path(conn, :show, absent)
      assert html_response(conn, 200) =~ "some updated reason"
    end

    test "renders errors when data is invalid", %{conn: conn, absent: absent} do
      conn = put conn, absent_path(conn, :update, absent), absent: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Absent"
    end
  end

  describe "delete absent" do
    setup [:create_absent]

    test "deletes chosen absent", %{conn: conn, absent: absent} do
      conn = delete conn, absent_path(conn, :delete, absent)
      assert redirected_to(conn) == absent_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, absent_path(conn, :show, absent)
      end
    end
  end

  defp create_absent(_) do
    absent = fixture(:absent)
    {:ok, absent: absent}
  end
end
