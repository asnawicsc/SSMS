defmodule SchoolWeb.EdisciplineControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{message: "some message", psid: "some psid", teacher_id: 42, title: "some title"}
  @update_attrs %{message: "some updated message", psid: "some updated psid", teacher_id: 43, title: "some updated title"}
  @invalid_attrs %{message: nil, psid: nil, teacher_id: nil, title: nil}

  def fixture(:ediscipline) do
    {:ok, ediscipline} = Affairs.create_ediscipline(@create_attrs)
    ediscipline
  end

  describe "index" do
    test "lists all edisciplines", %{conn: conn} do
      conn = get conn, ediscipline_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Edisciplines"
    end
  end

  describe "new ediscipline" do
    test "renders form", %{conn: conn} do
      conn = get conn, ediscipline_path(conn, :new)
      assert html_response(conn, 200) =~ "New Ediscipline"
    end
  end

  describe "create ediscipline" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, ediscipline_path(conn, :create), ediscipline: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ediscipline_path(conn, :show, id)

      conn = get conn, ediscipline_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Ediscipline"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, ediscipline_path(conn, :create), ediscipline: @invalid_attrs
      assert html_response(conn, 200) =~ "New Ediscipline"
    end
  end

  describe "edit ediscipline" do
    setup [:create_ediscipline]

    test "renders form for editing chosen ediscipline", %{conn: conn, ediscipline: ediscipline} do
      conn = get conn, ediscipline_path(conn, :edit, ediscipline)
      assert html_response(conn, 200) =~ "Edit Ediscipline"
    end
  end

  describe "update ediscipline" do
    setup [:create_ediscipline]

    test "redirects when data is valid", %{conn: conn, ediscipline: ediscipline} do
      conn = put conn, ediscipline_path(conn, :update, ediscipline), ediscipline: @update_attrs
      assert redirected_to(conn) == ediscipline_path(conn, :show, ediscipline)

      conn = get conn, ediscipline_path(conn, :show, ediscipline)
      assert html_response(conn, 200) =~ "some updated psid"
    end

    test "renders errors when data is invalid", %{conn: conn, ediscipline: ediscipline} do
      conn = put conn, ediscipline_path(conn, :update, ediscipline), ediscipline: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Ediscipline"
    end
  end

  describe "delete ediscipline" do
    setup [:create_ediscipline]

    test "deletes chosen ediscipline", %{conn: conn, ediscipline: ediscipline} do
      conn = delete conn, ediscipline_path(conn, :delete, ediscipline)
      assert redirected_to(conn) == ediscipline_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, ediscipline_path(conn, :show, ediscipline)
      end
    end
  end

  defp create_ediscipline(_) do
    ediscipline = fixture(:ediscipline)
    {:ok, ediscipline: ediscipline}
  end
end
