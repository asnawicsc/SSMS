defmodule SchoolWeb.ExamGradeControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{gpa: "120.5", institution_id: 42, max: 42, min: 42, name: "some name"}
  @update_attrs %{gpa: "456.7", institution_id: 43, max: 43, min: 43, name: "some updated name"}
  @invalid_attrs %{gpa: nil, institution_id: nil, max: nil, min: nil, name: nil}

  def fixture(:exam_grade) do
    {:ok, exam_grade} = Affairs.create_exam_grade(@create_attrs)
    exam_grade
  end

  describe "index" do
    test "lists all exam_grade", %{conn: conn} do
      conn = get conn, exam_grade_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Exam grade"
    end
  end

  describe "new exam_grade" do
    test "renders form", %{conn: conn} do
      conn = get conn, exam_grade_path(conn, :new)
      assert html_response(conn, 200) =~ "New Exam grade"
    end
  end

  describe "create exam_grade" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, exam_grade_path(conn, :create), exam_grade: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == exam_grade_path(conn, :show, id)

      conn = get conn, exam_grade_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Exam grade"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, exam_grade_path(conn, :create), exam_grade: @invalid_attrs
      assert html_response(conn, 200) =~ "New Exam grade"
    end
  end

  describe "edit exam_grade" do
    setup [:create_exam_grade]

    test "renders form for editing chosen exam_grade", %{conn: conn, exam_grade: exam_grade} do
      conn = get conn, exam_grade_path(conn, :edit, exam_grade)
      assert html_response(conn, 200) =~ "Edit Exam grade"
    end
  end

  describe "update exam_grade" do
    setup [:create_exam_grade]

    test "redirects when data is valid", %{conn: conn, exam_grade: exam_grade} do
      conn = put conn, exam_grade_path(conn, :update, exam_grade), exam_grade: @update_attrs
      assert redirected_to(conn) == exam_grade_path(conn, :show, exam_grade)

      conn = get conn, exam_grade_path(conn, :show, exam_grade)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, exam_grade: exam_grade} do
      conn = put conn, exam_grade_path(conn, :update, exam_grade), exam_grade: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Exam grade"
    end
  end

  describe "delete exam_grade" do
    setup [:create_exam_grade]

    test "deletes chosen exam_grade", %{conn: conn, exam_grade: exam_grade} do
      conn = delete conn, exam_grade_path(conn, :delete, exam_grade)
      assert redirected_to(conn) == exam_grade_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, exam_grade_path(conn, :show, exam_grade)
      end
    end
  end

  defp create_exam_grade(_) do
    exam_grade = fixture(:exam_grade)
    {:ok, exam_grade: exam_grade}
  end
end
