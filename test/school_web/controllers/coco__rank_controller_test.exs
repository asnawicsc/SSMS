defmodule SchoolWeb.Coco_RankControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{rank: "some rank", sub_category: "some sub_category"}
  @update_attrs %{rank: "some updated rank", sub_category: "some updated sub_category"}
  @invalid_attrs %{rank: nil, sub_category: nil}

  def fixture(:coco__rank) do
    {:ok, coco__rank} = Affairs.create_coco__rank(@create_attrs)
    coco__rank
  end

  describe "index" do
    test "lists all coco_ranks", %{conn: conn} do
      conn = get conn, coco__rank_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Coco ranks"
    end
  end

  describe "new coco__rank" do
    test "renders form", %{conn: conn} do
      conn = get conn, coco__rank_path(conn, :new)
      assert html_response(conn, 200) =~ "New Coco  rank"
    end
  end

  describe "create coco__rank" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, coco__rank_path(conn, :create), coco__rank: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == coco__rank_path(conn, :show, id)

      conn = get conn, coco__rank_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Coco  rank"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, coco__rank_path(conn, :create), coco__rank: @invalid_attrs
      assert html_response(conn, 200) =~ "New Coco  rank"
    end
  end

  describe "edit coco__rank" do
    setup [:create_coco__rank]

    test "renders form for editing chosen coco__rank", %{conn: conn, coco__rank: coco__rank} do
      conn = get conn, coco__rank_path(conn, :edit, coco__rank)
      assert html_response(conn, 200) =~ "Edit Coco  rank"
    end
  end

  describe "update coco__rank" do
    setup [:create_coco__rank]

    test "redirects when data is valid", %{conn: conn, coco__rank: coco__rank} do
      conn = put conn, coco__rank_path(conn, :update, coco__rank), coco__rank: @update_attrs
      assert redirected_to(conn) == coco__rank_path(conn, :show, coco__rank)

      conn = get conn, coco__rank_path(conn, :show, coco__rank)
      assert html_response(conn, 200) =~ "some updated rank"
    end

    test "renders errors when data is invalid", %{conn: conn, coco__rank: coco__rank} do
      conn = put conn, coco__rank_path(conn, :update, coco__rank), coco__rank: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Coco  rank"
    end
  end

  describe "delete coco__rank" do
    setup [:create_coco__rank]

    test "deletes chosen coco__rank", %{conn: conn, coco__rank: coco__rank} do
      conn = delete conn, coco__rank_path(conn, :delete, coco__rank)
      assert redirected_to(conn) == coco__rank_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, coco__rank_path(conn, :show, coco__rank)
      end
    end
  end

  defp create_coco__rank(_) do
    coco__rank = fixture(:coco__rank)
    {:ok, coco__rank: coco__rank}
  end
end
