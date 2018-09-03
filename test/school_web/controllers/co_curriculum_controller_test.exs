defmodule SchoolWeb.CoCurriculumControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  def fixture(:co_curriculum) do
    {:ok, co_curriculum} = Affairs.create_co_curriculum(@create_attrs)
    co_curriculum
  end

  describe "index" do
    test "lists all cocurriculum", %{conn: conn} do
      conn = get conn, co_curriculum_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Cocurriculum"
    end
  end

  describe "new co_curriculum" do
    test "renders form", %{conn: conn} do
      conn = get conn, co_curriculum_path(conn, :new)
      assert html_response(conn, 200) =~ "New Co curriculum"
    end
  end

  describe "create co_curriculum" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, co_curriculum_path(conn, :create), co_curriculum: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == co_curriculum_path(conn, :show, id)

      conn = get conn, co_curriculum_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Co curriculum"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, co_curriculum_path(conn, :create), co_curriculum: @invalid_attrs
      assert html_response(conn, 200) =~ "New Co curriculum"
    end
  end

  describe "edit co_curriculum" do
    setup [:create_co_curriculum]

    test "renders form for editing chosen co_curriculum", %{conn: conn, co_curriculum: co_curriculum} do
      conn = get conn, co_curriculum_path(conn, :edit, co_curriculum)
      assert html_response(conn, 200) =~ "Edit Co curriculum"
    end
  end

  describe "update co_curriculum" do
    setup [:create_co_curriculum]

    test "redirects when data is valid", %{conn: conn, co_curriculum: co_curriculum} do
      conn = put conn, co_curriculum_path(conn, :update, co_curriculum), co_curriculum: @update_attrs
      assert redirected_to(conn) == co_curriculum_path(conn, :show, co_curriculum)

      conn = get conn, co_curriculum_path(conn, :show, co_curriculum)
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, co_curriculum: co_curriculum} do
      conn = put conn, co_curriculum_path(conn, :update, co_curriculum), co_curriculum: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Co curriculum"
    end
  end

  describe "delete co_curriculum" do
    setup [:create_co_curriculum]

    test "deletes chosen co_curriculum", %{conn: conn, co_curriculum: co_curriculum} do
      conn = delete conn, co_curriculum_path(conn, :delete, co_curriculum)
      assert redirected_to(conn) == co_curriculum_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, co_curriculum_path(conn, :show, co_curriculum)
      end
    end
  end

  defp create_co_curriculum(_) do
    co_curriculum = fixture(:co_curriculum)
    {:ok, co_curriculum: co_curriculum}
  end
end
