defmodule SchoolWeb.ListRankControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{integer: "some integer", mark: "some mark", name: "some name"}
  @update_attrs %{integer: "some updated integer", mark: "some updated mark", name: "some updated name"}
  @invalid_attrs %{integer: nil, mark: nil, name: nil}

  def fixture(:list_rank) do
    {:ok, list_rank} = Affairs.create_list_rank(@create_attrs)
    list_rank
  end

  describe "index" do
    test "lists all list_rank", %{conn: conn} do
      conn = get conn, list_rank_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing List rank"
    end
  end

  describe "new list_rank" do
    test "renders form", %{conn: conn} do
      conn = get conn, list_rank_path(conn, :new)
      assert html_response(conn, 200) =~ "New List rank"
    end
  end

  describe "create list_rank" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, list_rank_path(conn, :create), list_rank: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == list_rank_path(conn, :show, id)

      conn = get conn, list_rank_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show List rank"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, list_rank_path(conn, :create), list_rank: @invalid_attrs
      assert html_response(conn, 200) =~ "New List rank"
    end
  end

  describe "edit list_rank" do
    setup [:create_list_rank]

    test "renders form for editing chosen list_rank", %{conn: conn, list_rank: list_rank} do
      conn = get conn, list_rank_path(conn, :edit, list_rank)
      assert html_response(conn, 200) =~ "Edit List rank"
    end
  end

  describe "update list_rank" do
    setup [:create_list_rank]

    test "redirects when data is valid", %{conn: conn, list_rank: list_rank} do
      conn = put conn, list_rank_path(conn, :update, list_rank), list_rank: @update_attrs
      assert redirected_to(conn) == list_rank_path(conn, :show, list_rank)

      conn = get conn, list_rank_path(conn, :show, list_rank)
      assert html_response(conn, 200) =~ "some updated integer"
    end

    test "renders errors when data is invalid", %{conn: conn, list_rank: list_rank} do
      conn = put conn, list_rank_path(conn, :update, list_rank), list_rank: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit List rank"
    end
  end

  describe "delete list_rank" do
    setup [:create_list_rank]

    test "deletes chosen list_rank", %{conn: conn, list_rank: list_rank} do
      conn = delete conn, list_rank_path(conn, :delete, list_rank)
      assert redirected_to(conn) == list_rank_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, list_rank_path(conn, :show, list_rank)
      end
    end
  end

  defp create_list_rank(_) do
    list_rank = fixture(:list_rank)
    {:ok, list_rank: list_rank}
  end
end
