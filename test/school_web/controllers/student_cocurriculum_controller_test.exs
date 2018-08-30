defmodule SchoolWeb.StudentCocurriculumControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{cocurriculum_id: 42, grade: "some grade", mark: 42, standard_id: 42, student_id: 42}
  @update_attrs %{cocurriculum_id: 43, grade: "some updated grade", mark: 43, standard_id: 43, student_id: 43}
  @invalid_attrs %{cocurriculum_id: nil, grade: nil, mark: nil, standard_id: nil, student_id: nil}

  def fixture(:student_cocurriculum) do
    {:ok, student_cocurriculum} = Affairs.create_student_cocurriculum(@create_attrs)
    student_cocurriculum
  end

  describe "index" do
    test "lists all student_cocurriculum", %{conn: conn} do
      conn = get conn, student_cocurriculum_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Student cocurriculum"
    end
  end

  describe "new student_cocurriculum" do
    test "renders form", %{conn: conn} do
      conn = get conn, student_cocurriculum_path(conn, :new)
      assert html_response(conn, 200) =~ "New Student cocurriculum"
    end
  end

  describe "create student_cocurriculum" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, student_cocurriculum_path(conn, :create), student_cocurriculum: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == student_cocurriculum_path(conn, :show, id)

      conn = get conn, student_cocurriculum_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Student cocurriculum"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, student_cocurriculum_path(conn, :create), student_cocurriculum: @invalid_attrs
      assert html_response(conn, 200) =~ "New Student cocurriculum"
    end
  end

  describe "edit student_cocurriculum" do
    setup [:create_student_cocurriculum]

    test "renders form for editing chosen student_cocurriculum", %{conn: conn, student_cocurriculum: student_cocurriculum} do
      conn = get conn, student_cocurriculum_path(conn, :edit, student_cocurriculum)
      assert html_response(conn, 200) =~ "Edit Student cocurriculum"
    end
  end

  describe "update student_cocurriculum" do
    setup [:create_student_cocurriculum]

    test "redirects when data is valid", %{conn: conn, student_cocurriculum: student_cocurriculum} do
      conn = put conn, student_cocurriculum_path(conn, :update, student_cocurriculum), student_cocurriculum: @update_attrs
      assert redirected_to(conn) == student_cocurriculum_path(conn, :show, student_cocurriculum)

      conn = get conn, student_cocurriculum_path(conn, :show, student_cocurriculum)
      assert html_response(conn, 200) =~ "some updated grade"
    end

    test "renders errors when data is invalid", %{conn: conn, student_cocurriculum: student_cocurriculum} do
      conn = put conn, student_cocurriculum_path(conn, :update, student_cocurriculum), student_cocurriculum: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Student cocurriculum"
    end
  end

  describe "delete student_cocurriculum" do
    setup [:create_student_cocurriculum]

    test "deletes chosen student_cocurriculum", %{conn: conn, student_cocurriculum: student_cocurriculum} do
      conn = delete conn, student_cocurriculum_path(conn, :delete, student_cocurriculum)
      assert redirected_to(conn) == student_cocurriculum_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, student_cocurriculum_path(conn, :show, student_cocurriculum)
      end
    end
  end

  defp create_student_cocurriculum(_) do
    student_cocurriculum = fixture(:student_cocurriculum)
    {:ok, student_cocurriculum: student_cocurriculum}
  end
end
