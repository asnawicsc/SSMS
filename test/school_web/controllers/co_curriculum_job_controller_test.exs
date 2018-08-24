defmodule SchoolWeb.CoCurriculumJobControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{cdesc: "some cdesc", code: "some code", description: "some description"}
  @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description"}
  @invalid_attrs %{cdesc: nil, code: nil, description: nil}

  def fixture(:co_curriculum_job) do
    {:ok, co_curriculum_job} = Affairs.create_co_curriculum_job(@create_attrs)
    co_curriculum_job
  end

  describe "index" do
    test "lists all cocurriculum_job", %{conn: conn} do
      conn = get conn, co_curriculum_job_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Cocurriculum job"
    end
  end

  describe "new co_curriculum_job" do
    test "renders form", %{conn: conn} do
      conn = get conn, co_curriculum_job_path(conn, :new)
      assert html_response(conn, 200) =~ "New Co curriculum job"
    end
  end

  describe "create co_curriculum_job" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, co_curriculum_job_path(conn, :create), co_curriculum_job: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == co_curriculum_job_path(conn, :show, id)

      conn = get conn, co_curriculum_job_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Co curriculum job"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, co_curriculum_job_path(conn, :create), co_curriculum_job: @invalid_attrs
      assert html_response(conn, 200) =~ "New Co curriculum job"
    end
  end

  describe "edit co_curriculum_job" do
    setup [:create_co_curriculum_job]

    test "renders form for editing chosen co_curriculum_job", %{conn: conn, co_curriculum_job: co_curriculum_job} do
      conn = get conn, co_curriculum_job_path(conn, :edit, co_curriculum_job)
      assert html_response(conn, 200) =~ "Edit Co curriculum job"
    end
  end

  describe "update co_curriculum_job" do
    setup [:create_co_curriculum_job]

    test "redirects when data is valid", %{conn: conn, co_curriculum_job: co_curriculum_job} do
      conn = put conn, co_curriculum_job_path(conn, :update, co_curriculum_job), co_curriculum_job: @update_attrs
      assert redirected_to(conn) == co_curriculum_job_path(conn, :show, co_curriculum_job)

      conn = get conn, co_curriculum_job_path(conn, :show, co_curriculum_job)
      assert html_response(conn, 200) =~ "some updated cdesc"
    end

    test "renders errors when data is invalid", %{conn: conn, co_curriculum_job: co_curriculum_job} do
      conn = put conn, co_curriculum_job_path(conn, :update, co_curriculum_job), co_curriculum_job: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Co curriculum job"
    end
  end

  describe "delete co_curriculum_job" do
    setup [:create_co_curriculum_job]

    test "deletes chosen co_curriculum_job", %{conn: conn, co_curriculum_job: co_curriculum_job} do
      conn = delete conn, co_curriculum_job_path(conn, :delete, co_curriculum_job)
      assert redirected_to(conn) == co_curriculum_job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, co_curriculum_job_path(conn, :show, co_curriculum_job)
      end
    end
  end

  defp create_co_curriculum_job(_) do
    co_curriculum_job = fixture(:co_curriculum_job)
    {:ok, co_curriculum_job: co_curriculum_job}
  end
end
