defmodule SchoolWeb.RakanControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{max: 42, min: 42, prize: "some prize", standard_id: 42}
  @update_attrs %{max: 43, min: 43, prize: "some updated prize", standard_id: 43}
  @invalid_attrs %{max: nil, min: nil, prize: nil, standard_id: nil}

  def fixture(:rakan) do
    {:ok, rakan} = Affairs.create_rakan(@create_attrs)
    rakan
  end

  describe "index" do
    test "lists all rakan", %{conn: conn} do
      conn = get conn, rakan_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Rakan"
    end
  end

  describe "new rakan" do
    test "renders form", %{conn: conn} do
      conn = get conn, rakan_path(conn, :new)
      assert html_response(conn, 200) =~ "New Rakan"
    end
  end

  describe "create rakan" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, rakan_path(conn, :create), rakan: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == rakan_path(conn, :show, id)

      conn = get conn, rakan_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Rakan"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, rakan_path(conn, :create), rakan: @invalid_attrs
      assert html_response(conn, 200) =~ "New Rakan"
    end
  end

  describe "edit rakan" do
    setup [:create_rakan]

    test "renders form for editing chosen rakan", %{conn: conn, rakan: rakan} do
      conn = get conn, rakan_path(conn, :edit, rakan)
      assert html_response(conn, 200) =~ "Edit Rakan"
    end
  end

  describe "update rakan" do
    setup [:create_rakan]

    test "redirects when data is valid", %{conn: conn, rakan: rakan} do
      conn = put conn, rakan_path(conn, :update, rakan), rakan: @update_attrs
      assert redirected_to(conn) == rakan_path(conn, :show, rakan)

      conn = get conn, rakan_path(conn, :show, rakan)
      assert html_response(conn, 200) =~ "some updated prize"
    end

    test "renders errors when data is invalid", %{conn: conn, rakan: rakan} do
      conn = put conn, rakan_path(conn, :update, rakan), rakan: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Rakan"
    end
  end

  describe "delete rakan" do
    setup [:create_rakan]

    test "deletes chosen rakan", %{conn: conn, rakan: rakan} do
      conn = delete conn, rakan_path(conn, :delete, rakan)
      assert redirected_to(conn) == rakan_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, rakan_path(conn, :show, rakan)
      end
    end
  end

  defp create_rakan(_) do
    rakan = fixture(:rakan)
    {:ok, rakan: rakan}
  end
end
