defmodule SchoolWeb.EhomeworkControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, end_date: ~D[2010-04-17], semester_id: 42, start_date: ~D[2010-04-17], subject_id: 42}
  @update_attrs %{class_id: 43, end_date: ~D[2011-05-18], semester_id: 43, start_date: ~D[2011-05-18], subject_id: 43}
  @invalid_attrs %{class_id: nil, end_date: nil, semester_id: nil, start_date: nil, subject_id: nil}

  def fixture(:ehomework) do
    {:ok, ehomework} = Affairs.create_ehomework(@create_attrs)
    ehomework
  end

  describe "index" do
    test "lists all ehehomeworks", %{conn: conn} do
      conn = get conn, ehomework_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Ehehomeworks"
    end
  end

  describe "new ehomework" do
    test "renders form", %{conn: conn} do
      conn = get conn, ehomework_path(conn, :new)
      assert html_response(conn, 200) =~ "New Ehomework"
    end
  end

  describe "create ehomework" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ehomework_path(conn, :create), ehomework: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ehomework_path(conn, :show, id)

      conn = get conn, ehomework_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Ehomework"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ehomework_path(conn, :create), ehomework: @invalid_attrs
      assert html_response(conn, 200) =~ "New Ehomework"
    end
  end

  describe "edit ehomework" do
    setup [:create_ehomework]

    test "renders form for editing chosen ehomework", %{conn: conn, ehomework: ehomework} do
      conn = get conn, ehomework_path(conn, :edit, ehomework)
      assert html_response(conn, 200) =~ "Edit Ehomework"
    end
  end

  describe "update ehomework" do
    setup [:create_ehomework]

    test "redirects when data is valid", %{conn: conn, ehomework: ehomework} do
      conn = put conn, ehomework_path(conn, :update, ehomework), ehomework: @update_attrs
      assert redirected_to(conn) == ehomework_path(conn, :show, ehomework)

      conn = get conn, ehomework_path(conn, :show, ehomework)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, ehomework: ehomework} do
      conn = put conn, ehomework_path(conn, :update, ehomework), ehomework: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Ehomework"
    end
  end

  describe "delete ehomework" do
    setup [:create_ehomework]

    test "deletes chosen ehomework", %{conn: conn, ehomework: ehomework} do
      conn = delete conn, ehomework_path(conn, :delete, ehomework)
      assert redirected_to(conn) == ehomework_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, ehomework_path(conn, :show, ehomework)
      end
    end
  end

  defp create_ehomework(_) do
    ehomework = fixture(:ehomework)
    {:ok, ehomework: ehomework}
  end
end
