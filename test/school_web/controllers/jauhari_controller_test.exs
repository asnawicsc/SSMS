defmodule SchoolWeb.JauhariControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{max: 42, min: 42, prize: "some prize"}
  @update_attrs %{max: 43, min: 43, prize: "some updated prize"}
  @invalid_attrs %{max: nil, min: nil, prize: nil}

  def fixture(:jauhari) do
    {:ok, jauhari} = Affairs.create_jauhari(@create_attrs)
    jauhari
  end

  describe "index" do
    test "lists all jauhari", %{conn: conn} do
      conn = get conn, jauhari_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Jauhari"
    end
  end

  describe "new jauhari" do
    test "renders form", %{conn: conn} do
      conn = get conn, jauhari_path(conn, :new)
      assert html_response(conn, 200) =~ "New Jauhari"
    end
  end

  describe "create jauhari" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, jauhari_path(conn, :create), jauhari: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == jauhari_path(conn, :show, id)

      conn = get conn, jauhari_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Jauhari"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, jauhari_path(conn, :create), jauhari: @invalid_attrs
      assert html_response(conn, 200) =~ "New Jauhari"
    end
  end

  describe "edit jauhari" do
    setup [:create_jauhari]

    test "renders form for editing chosen jauhari", %{conn: conn, jauhari: jauhari} do
      conn = get conn, jauhari_path(conn, :edit, jauhari)
      assert html_response(conn, 200) =~ "Edit Jauhari"
    end
  end

  describe "update jauhari" do
    setup [:create_jauhari]

    test "redirects when data is valid", %{conn: conn, jauhari: jauhari} do
      conn = put conn, jauhari_path(conn, :update, jauhari), jauhari: @update_attrs
      assert redirected_to(conn) == jauhari_path(conn, :show, jauhari)

      conn = get conn, jauhari_path(conn, :show, jauhari)
      assert html_response(conn, 200) =~ "some updated prize"
    end

    test "renders errors when data is invalid", %{conn: conn, jauhari: jauhari} do
      conn = put conn, jauhari_path(conn, :update, jauhari), jauhari: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Jauhari"
    end
  end

  describe "delete jauhari" do
    setup [:create_jauhari]

    test "deletes chosen jauhari", %{conn: conn, jauhari: jauhari} do
      conn = delete conn, jauhari_path(conn, :delete, jauhari)
      assert redirected_to(conn) == jauhari_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, jauhari_path(conn, :show, jauhari)
      end
    end
  end

  defp create_jauhari(_) do
    jauhari = fixture(:jauhari)
    {:ok, jauhari: jauhari}
  end
end
