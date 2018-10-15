defmodule SchoolWeb.ContactUsControllerTest do
  use SchoolWeb.ConnCase

  alias School.Setting

  @create_attrs %{email: "some email", message: "some message", name: "some name"}
  @update_attrs %{email: "some updated email", message: "some updated message", name: "some updated name"}
  @invalid_attrs %{email: nil, message: nil, name: nil}

  def fixture(:contact_us) do
    {:ok, contact_us} = Setting.create_contact_us(@create_attrs)
    contact_us
  end

  describe "index" do
    test "lists all contact_us", %{conn: conn} do
      conn = get conn, contact_us_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Contact us"
    end
  end

  describe "new contact_us" do
    test "renders form", %{conn: conn} do
      conn = get conn, contact_us_path(conn, :new)
      assert html_response(conn, 200) =~ "New Contact us"
    end
  end

  describe "create contact_us" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, contact_us_path(conn, :create), contact_us: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == contact_us_path(conn, :show, id)

      conn = get conn, contact_us_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Contact us"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, contact_us_path(conn, :create), contact_us: @invalid_attrs
      assert html_response(conn, 200) =~ "New Contact us"
    end
  end

  describe "edit contact_us" do
    setup [:create_contact_us]

    test "renders form for editing chosen contact_us", %{conn: conn, contact_us: contact_us} do
      conn = get conn, contact_us_path(conn, :edit, contact_us)
      assert html_response(conn, 200) =~ "Edit Contact us"
    end
  end

  describe "update contact_us" do
    setup [:create_contact_us]

    test "redirects when data is valid", %{conn: conn, contact_us: contact_us} do
      conn = put conn, contact_us_path(conn, :update, contact_us), contact_us: @update_attrs
      assert redirected_to(conn) == contact_us_path(conn, :show, contact_us)

      conn = get conn, contact_us_path(conn, :show, contact_us)
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, contact_us: contact_us} do
      conn = put conn, contact_us_path(conn, :update, contact_us), contact_us: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Contact us"
    end
  end

  describe "delete contact_us" do
    setup [:create_contact_us]

    test "deletes chosen contact_us", %{conn: conn, contact_us: contact_us} do
      conn = delete conn, contact_us_path(conn, :delete, contact_us)
      assert redirected_to(conn) == contact_us_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, contact_us_path(conn, :show, contact_us)
      end
    end
  end

  defp create_contact_us(_) do
    contact_us = fixture(:contact_us)
    {:ok, contact_us: contact_us}
  end
end
