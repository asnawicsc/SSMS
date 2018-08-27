defmodule SchoolWeb.HemJobControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{cdesc: "some cdesc", code: "some code", description: "some description"}
  @update_attrs %{cdesc: "some updated cdesc", code: "some updated code", description: "some updated description"}
  @invalid_attrs %{cdesc: nil, code: nil, description: nil}

  def fixture(:hem_job) do
    {:ok, hem_job} = Affairs.create_hem_job(@create_attrs)
    hem_job
  end

  describe "index" do
    test "lists all hem_job", %{conn: conn} do
      conn = get conn, hem_job_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Hem job"
    end
  end

  describe "new hem_job" do
    test "renders form", %{conn: conn} do
      conn = get conn, hem_job_path(conn, :new)
      assert html_response(conn, 200) =~ "New Hem job"
    end
  end

  describe "create hem_job" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, hem_job_path(conn, :create), hem_job: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == hem_job_path(conn, :show, id)

      conn = get conn, hem_job_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Hem job"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, hem_job_path(conn, :create), hem_job: @invalid_attrs
      assert html_response(conn, 200) =~ "New Hem job"
    end
  end

  describe "edit hem_job" do
    setup [:create_hem_job]

    test "renders form for editing chosen hem_job", %{conn: conn, hem_job: hem_job} do
      conn = get conn, hem_job_path(conn, :edit, hem_job)
      assert html_response(conn, 200) =~ "Edit Hem job"
    end
  end

  describe "update hem_job" do
    setup [:create_hem_job]

    test "redirects when data is valid", %{conn: conn, hem_job: hem_job} do
      conn = put conn, hem_job_path(conn, :update, hem_job), hem_job: @update_attrs
      assert redirected_to(conn) == hem_job_path(conn, :show, hem_job)

      conn = get conn, hem_job_path(conn, :show, hem_job)
      assert html_response(conn, 200) =~ "some updated cdesc"
    end

    test "renders errors when data is invalid", %{conn: conn, hem_job: hem_job} do
      conn = put conn, hem_job_path(conn, :update, hem_job), hem_job: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Hem job"
    end
  end

  describe "delete hem_job" do
    setup [:create_hem_job]

    test "deletes chosen hem_job", %{conn: conn, hem_job: hem_job} do
      conn = delete conn, hem_job_path(conn, :delete, hem_job)
      assert redirected_to(conn) == hem_job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, hem_job_path(conn, :show, hem_job)
      end
    end
  end

  defp create_hem_job(_) do
    hem_job = fixture(:hem_job)
    {:ok, hem_job: hem_job}
  end
end
