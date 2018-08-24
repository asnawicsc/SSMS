defmodule SchoolWeb.SchoolJobControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{cdesc: "some cdesc", code: "some code", description: "some description"}
  @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description"}
  @invalid_attrs %{cdesc: nil, code: nil, description: nil}

  def fixture(:school_job) do
    {:ok, school_job} = Affairs.create_school_job(@create_attrs)
    school_job
  end

  describe "index" do
    test "lists all school_job", %{conn: conn} do
      conn = get conn, school_job_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing School job"
    end
  end

  describe "new school_job" do
    test "renders form", %{conn: conn} do
      conn = get conn, school_job_path(conn, :new)
      assert html_response(conn, 200) =~ "New School job"
    end
  end

  describe "create school_job" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, school_job_path(conn, :create), school_job: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == school_job_path(conn, :show, id)

      conn = get conn, school_job_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show School job"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, school_job_path(conn, :create), school_job: @invalid_attrs
      assert html_response(conn, 200) =~ "New School job"
    end
  end

  describe "edit school_job" do
    setup [:create_school_job]

    test "renders form for editing chosen school_job", %{conn: conn, school_job: school_job} do
      conn = get conn, school_job_path(conn, :edit, school_job)
      assert html_response(conn, 200) =~ "Edit School job"
    end
  end

  describe "update school_job" do
    setup [:create_school_job]

    test "redirects when data is valid", %{conn: conn, school_job: school_job} do
      conn = put conn, school_job_path(conn, :update, school_job), school_job: @update_attrs
      assert redirected_to(conn) == school_job_path(conn, :show, school_job)

      conn = get conn, school_job_path(conn, :show, school_job)
      assert html_response(conn, 200) =~ "some updated cdesc"
    end

    test "renders errors when data is invalid", %{conn: conn, school_job: school_job} do
      conn = put conn, school_job_path(conn, :update, school_job), school_job: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit School job"
    end
  end

  describe "delete school_job" do
    setup [:create_school_job]

    test "deletes chosen school_job", %{conn: conn, school_job: school_job} do
      conn = delete conn, school_job_path(conn, :delete, school_job)
      assert redirected_to(conn) == school_job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, school_job_path(conn, :show, school_job)
      end
    end
  end

  defp create_school_job(_) do
    school_job = fixture(:school_job)
    {:ok, school_job: school_job}
  end
end
