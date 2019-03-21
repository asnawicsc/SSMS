defmodule SchoolWeb.ShiftControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{shift_master_id: 42, teacher_id: 42}
  @update_attrs %{shift_master_id: 43, teacher_id: 43}
  @invalid_attrs %{shift_master_id: nil, teacher_id: nil}

  def fixture(:shift) do
    {:ok, shift} = Affairs.create_shift(@create_attrs)
    shift
  end

  describe "index" do
    test "lists all shift", %{conn: conn} do
      conn = get conn, shift_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Shift"
    end
  end

  describe "new shift" do
    test "renders form", %{conn: conn} do
      conn = get conn, shift_path(conn, :new)
      assert html_response(conn, 200) =~ "New Shift"
    end
  end

  describe "create shift" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, shift_path(conn, :create), shift: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == shift_path(conn, :show, id)

      conn = get conn, shift_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Shift"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, shift_path(conn, :create), shift: @invalid_attrs
      assert html_response(conn, 200) =~ "New Shift"
    end
  end

  describe "edit shift" do
    setup [:create_shift]

    test "renders form for editing chosen shift", %{conn: conn, shift: shift} do
      conn = get conn, shift_path(conn, :edit, shift)
      assert html_response(conn, 200) =~ "Edit Shift"
    end
  end

  describe "update shift" do
    setup [:create_shift]

    test "redirects when data is valid", %{conn: conn, shift: shift} do
      conn = put conn, shift_path(conn, :update, shift), shift: @update_attrs
      assert redirected_to(conn) == shift_path(conn, :show, shift)

      conn = get conn, shift_path(conn, :show, shift)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, shift: shift} do
      conn = put conn, shift_path(conn, :update, shift), shift: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Shift"
    end
  end

  describe "delete shift" do
    setup [:create_shift]

    test "deletes chosen shift", %{conn: conn, shift: shift} do
      conn = delete conn, shift_path(conn, :delete, shift)
      assert redirected_to(conn) == shift_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, shift_path(conn, :show, shift)
      end
    end
  end

  defp create_shift(_) do
    shift = fixture(:shift)
    {:ok, shift: shift}
  end
end
