defmodule SchoolWeb.UserAccessControllerTest do
  use SchoolWeb.ConnCase

  alias School.Settings

  @create_attrs %{institution_id: 42, user_id: 42}
  @update_attrs %{institution_id: 43, user_id: 43}
  @invalid_attrs %{institution_id: nil, user_id: nil}

  def fixture(:user_access) do
    {:ok, user_access} = Settings.create_user_access(@create_attrs)
    user_access
  end

  describe "index" do
    test "lists all user_access", %{conn: conn} do
      conn = get conn, user_access_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing User access"
    end
  end

  describe "new user_access" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_access_path(conn, :new)
      assert html_response(conn, 200) =~ "New User access"
    end
  end

  describe "create user_access" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, user_access_path(conn, :create), user_access: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == user_access_path(conn, :show, id)

      conn = get conn, user_access_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show User access"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_access_path(conn, :create), user_access: @invalid_attrs
      assert html_response(conn, 200) =~ "New User access"
    end
  end

  describe "edit user_access" do
    setup [:create_user_access]

    test "renders form for editing chosen user_access", %{conn: conn, user_access: user_access} do
      conn = get conn, user_access_path(conn, :edit, user_access)
      assert html_response(conn, 200) =~ "Edit User access"
    end
  end

  describe "update user_access" do
    setup [:create_user_access]

    test "redirects when data is valid", %{conn: conn, user_access: user_access} do
      conn = put conn, user_access_path(conn, :update, user_access), user_access: @update_attrs
      assert redirected_to(conn) == user_access_path(conn, :show, user_access)

      conn = get conn, user_access_path(conn, :show, user_access)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user_access: user_access} do
      conn = put conn, user_access_path(conn, :update, user_access), user_access: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User access"
    end
  end

  describe "delete user_access" do
    setup [:create_user_access]

    test "deletes chosen user_access", %{conn: conn, user_access: user_access} do
      conn = delete conn, user_access_path(conn, :delete, user_access)
      assert redirected_to(conn) == user_access_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, user_access_path(conn, :show, user_access)
      end
    end
  end

  defp create_user_access(_) do
    user_access = fixture(:user_access)
    {:ok, user_access: user_access}
  end
end
