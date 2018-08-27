defmodule SchoolWeb.TeacherSchoolJobControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{school_job_id: 42, semester_id: 42, teacher_id: 42}
  @update_attrs %{school_job_id: 43, semester_id: 43, teacher_id: 43}
  @invalid_attrs %{school_job_id: nil, semester_id: nil, teacher_id: nil}

  def fixture(:teacher_school_job) do
    {:ok, teacher_school_job} = Affairs.create_teacher_school_job(@create_attrs)
    teacher_school_job
  end

  describe "index" do
    test "lists all teacher_school_job", %{conn: conn} do
      conn = get conn, teacher_school_job_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teacher school job"
    end
  end

  describe "new teacher_school_job" do
    test "renders form", %{conn: conn} do
      conn = get conn, teacher_school_job_path(conn, :new)
      assert html_response(conn, 200) =~ "New Teacher school job"
    end
  end

  describe "create teacher_school_job" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, teacher_school_job_path(conn, :create), teacher_school_job: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == teacher_school_job_path(conn, :show, id)

      conn = get conn, teacher_school_job_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Teacher school job"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, teacher_school_job_path(conn, :create), teacher_school_job: @invalid_attrs
      assert html_response(conn, 200) =~ "New Teacher school job"
    end
  end

  describe "edit teacher_school_job" do
    setup [:create_teacher_school_job]

    test "renders form for editing chosen teacher_school_job", %{conn: conn, teacher_school_job: teacher_school_job} do
      conn = get conn, teacher_school_job_path(conn, :edit, teacher_school_job)
      assert html_response(conn, 200) =~ "Edit Teacher school job"
    end
  end

  describe "update teacher_school_job" do
    setup [:create_teacher_school_job]

    test "redirects when data is valid", %{conn: conn, teacher_school_job: teacher_school_job} do
      conn = put conn, teacher_school_job_path(conn, :update, teacher_school_job), teacher_school_job: @update_attrs
      assert redirected_to(conn) == teacher_school_job_path(conn, :show, teacher_school_job)

      conn = get conn, teacher_school_job_path(conn, :show, teacher_school_job)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, teacher_school_job: teacher_school_job} do
      conn = put conn, teacher_school_job_path(conn, :update, teacher_school_job), teacher_school_job: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Teacher school job"
    end
  end

  describe "delete teacher_school_job" do
    setup [:create_teacher_school_job]

    test "deletes chosen teacher_school_job", %{conn: conn, teacher_school_job: teacher_school_job} do
      conn = delete conn, teacher_school_job_path(conn, :delete, teacher_school_job)
      assert redirected_to(conn) == teacher_school_job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, teacher_school_job_path(conn, :show, teacher_school_job)
      end
    end
  end

  defp create_teacher_school_job(_) do
    teacher_school_job = fixture(:teacher_school_job)
    {:ok, teacher_school_job: teacher_school_job}
  end
end
