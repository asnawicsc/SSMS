defmodule SchoolWeb.SegakControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: "some class_id", institution_id: "some institution_id", mark: "some mark", semester_id: "some semester_id", standard_id: "some standard_id", student_id: "some student_id"}
  @update_attrs %{class_id: "some updated class_id", institution_id: "some updated institution_id", mark: "some updated mark", semester_id: "some updated semester_id", standard_id: "some updated standard_id", student_id: "some updated student_id"}
  @invalid_attrs %{class_id: nil, institution_id: nil, mark: nil, semester_id: nil, standard_id: nil, student_id: nil}

  def fixture(:segak) do
    {:ok, segak} = Affairs.create_segak(@create_attrs)
    segak
  end

  describe "index" do
    test "lists all segak", %{conn: conn} do
      conn = get conn, segak_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Segak"
    end
  end

  describe "new segak" do
    test "renders form", %{conn: conn} do
      conn = get conn, segak_path(conn, :new)
      assert html_response(conn, 200) =~ "New Segak"
    end
  end

  describe "create segak" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, segak_path(conn, :create), segak: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == segak_path(conn, :show, id)

      conn = get conn, segak_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Segak"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, segak_path(conn, :create), segak: @invalid_attrs
      assert html_response(conn, 200) =~ "New Segak"
    end
  end

  describe "edit segak" do
    setup [:create_segak]

    test "renders form for editing chosen segak", %{conn: conn, segak: segak} do
      conn = get conn, segak_path(conn, :edit, segak)
      assert html_response(conn, 200) =~ "Edit Segak"
    end
  end

  describe "update segak" do
    setup [:create_segak]

    test "redirects when data is valid", %{conn: conn, segak: segak} do
      conn = put conn, segak_path(conn, :update, segak), segak: @update_attrs
      assert redirected_to(conn) == segak_path(conn, :show, segak)

      conn = get conn, segak_path(conn, :show, segak)
      assert html_response(conn, 200) =~ "some updated class_id"
    end

    test "renders errors when data is invalid", %{conn: conn, segak: segak} do
      conn = put conn, segak_path(conn, :update, segak), segak: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Segak"
    end
  end

  describe "delete segak" do
    setup [:create_segak]

    test "deletes chosen segak", %{conn: conn, segak: segak} do
      conn = delete conn, segak_path(conn, :delete, segak)
      assert redirected_to(conn) == segak_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, segak_path(conn, :show, segak)
      end
    end
  end

  defp create_segak(_) do
    segak = fixture(:segak)
    {:ok, segak: segak}
  end
end
