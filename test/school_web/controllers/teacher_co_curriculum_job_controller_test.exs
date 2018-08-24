defmodule SchoolWeb.TeacherCoCurriculumJobControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{co_curriculum_job_id: 42, semester_id: 42, teacher_id: 42}
  @update_attrs %{co_curriculum_job_id: 43, semester_id: 43, teacher_id: 43}
  @invalid_attrs %{co_curriculum_job_id: nil, semester_id: nil, teacher_id: nil}

  def fixture(:teacher_co_curriculum_job) do
    {:ok, teacher_co_curriculum_job} = Affairs.create_teacher_co_curriculum_job(@create_attrs)
    teacher_co_curriculum_job
  end

  describe "index" do
    test "lists all teacher_co_curriculum_job", %{conn: conn} do
      conn = get conn, teacher_co_curriculum_job_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teacher co curriculum job"
    end
  end

  describe "new teacher_co_curriculum_job" do
    test "renders form", %{conn: conn} do
      conn = get conn, teacher_co_curriculum_job_path(conn, :new)
      assert html_response(conn, 200) =~ "New Teacher co curriculum job"
    end
  end

  describe "create teacher_co_curriculum_job" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, teacher_co_curriculum_job_path(conn, :create), teacher_co_curriculum_job: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == teacher_co_curriculum_job_path(conn, :show, id)

      conn = get conn, teacher_co_curriculum_job_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Teacher co curriculum job"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, teacher_co_curriculum_job_path(conn, :create), teacher_co_curriculum_job: @invalid_attrs
      assert html_response(conn, 200) =~ "New Teacher co curriculum job"
    end
  end

  describe "edit teacher_co_curriculum_job" do
    setup [:create_teacher_co_curriculum_job]

    test "renders form for editing chosen teacher_co_curriculum_job", %{conn: conn, teacher_co_curriculum_job: teacher_co_curriculum_job} do
      conn = get conn, teacher_co_curriculum_job_path(conn, :edit, teacher_co_curriculum_job)
      assert html_response(conn, 200) =~ "Edit Teacher co curriculum job"
    end
  end

  describe "update teacher_co_curriculum_job" do
    setup [:create_teacher_co_curriculum_job]

    test "redirects when data is valid", %{conn: conn, teacher_co_curriculum_job: teacher_co_curriculum_job} do
      conn = put conn, teacher_co_curriculum_job_path(conn, :update, teacher_co_curriculum_job), teacher_co_curriculum_job: @update_attrs
      assert redirected_to(conn) == teacher_co_curriculum_job_path(conn, :show, teacher_co_curriculum_job)

      conn = get conn, teacher_co_curriculum_job_path(conn, :show, teacher_co_curriculum_job)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, teacher_co_curriculum_job: teacher_co_curriculum_job} do
      conn = put conn, teacher_co_curriculum_job_path(conn, :update, teacher_co_curriculum_job), teacher_co_curriculum_job: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Teacher co curriculum job"
    end
  end

  describe "delete teacher_co_curriculum_job" do
    setup [:create_teacher_co_curriculum_job]

    test "deletes chosen teacher_co_curriculum_job", %{conn: conn, teacher_co_curriculum_job: teacher_co_curriculum_job} do
      conn = delete conn, teacher_co_curriculum_job_path(conn, :delete, teacher_co_curriculum_job)
      assert redirected_to(conn) == teacher_co_curriculum_job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, teacher_co_curriculum_job_path(conn, :show, teacher_co_curriculum_job)
      end
    end
  end

  defp create_teacher_co_curriculum_job(_) do
    teacher_co_curriculum_job = fixture(:teacher_co_curriculum_job)
    {:ok, teacher_co_curriculum_job: teacher_co_curriculum_job}
  end
end
