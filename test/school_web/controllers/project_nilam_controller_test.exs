defmodule SchoolWeb.ProjectNilamControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{below_satisfy: 42, count_page: 42, import_from_library: 42, member_reading_quantity: 42, page: 42, standard_id: 42}
  @update_attrs %{below_satisfy: 43, count_page: 43, import_from_library: 43, member_reading_quantity: 43, page: 43, standard_id: 43}
  @invalid_attrs %{below_satisfy: nil, count_page: nil, import_from_library: nil, member_reading_quantity: nil, page: nil, standard_id: nil}

  def fixture(:project_nilam) do
    {:ok, project_nilam} = Affairs.create_project_nilam(@create_attrs)
    project_nilam
  end

  describe "index" do
    test "lists all project_nilam", %{conn: conn} do
      conn = get conn, project_nilam_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Project nilam"
    end
  end

  describe "new project_nilam" do
    test "renders form", %{conn: conn} do
      conn = get conn, project_nilam_path(conn, :new)
      assert html_response(conn, 200) =~ "New Project nilam"
    end
  end

  describe "create project_nilam" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, project_nilam_path(conn, :create), project_nilam: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == project_nilam_path(conn, :show, id)

      conn = get conn, project_nilam_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Project nilam"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, project_nilam_path(conn, :create), project_nilam: @invalid_attrs
      assert html_response(conn, 200) =~ "New Project nilam"
    end
  end

  describe "edit project_nilam" do
    setup [:create_project_nilam]

    test "renders form for editing chosen project_nilam", %{conn: conn, project_nilam: project_nilam} do
      conn = get conn, project_nilam_path(conn, :edit, project_nilam)
      assert html_response(conn, 200) =~ "Edit Project nilam"
    end
  end

  describe "update project_nilam" do
    setup [:create_project_nilam]

    test "redirects when data is valid", %{conn: conn, project_nilam: project_nilam} do
      conn = put conn, project_nilam_path(conn, :update, project_nilam), project_nilam: @update_attrs
      assert redirected_to(conn) == project_nilam_path(conn, :show, project_nilam)

      conn = get conn, project_nilam_path(conn, :show, project_nilam)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, project_nilam: project_nilam} do
      conn = put conn, project_nilam_path(conn, :update, project_nilam), project_nilam: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Project nilam"
    end
  end

  describe "delete project_nilam" do
    setup [:create_project_nilam]

    test "deletes chosen project_nilam", %{conn: conn, project_nilam: project_nilam} do
      conn = delete conn, project_nilam_path(conn, :delete, project_nilam)
      assert redirected_to(conn) == project_nilam_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, project_nilam_path(conn, :show, project_nilam)
      end
    end
  end

  defp create_project_nilam(_) do
    project_nilam = fixture(:project_nilam)
    {:ok, project_nilam: project_nilam}
  end
end
