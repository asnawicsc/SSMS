defmodule SchoolWeb.ExamMarkControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, exam_id: 42, mark: 42, student_id: 42, subject_id: 42}
  @update_attrs %{class_id: 43, exam_id: 43, mark: 43, student_id: 43, subject_id: 43}
  @invalid_attrs %{class_id: nil, exam_id: nil, mark: nil, student_id: nil, subject_id: nil}

  def fixture(:exam_mark) do
    {:ok, exam_mark} = Affairs.create_exam_mark(@create_attrs)
    exam_mark
  end

  describe "index" do
    test "lists all exam_mark", %{conn: conn} do
      conn = get conn, exam_mark_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Exam mark"
    end
  end

  describe "new exam_mark" do
    test "renders form", %{conn: conn} do
      conn = get conn, exam_mark_path(conn, :new)
      assert html_response(conn, 200) =~ "New Exam mark"
    end
  end

  describe "create exam_mark" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, exam_mark_path(conn, :create), exam_mark: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == exam_mark_path(conn, :show, id)

      conn = get conn, exam_mark_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Exam mark"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, exam_mark_path(conn, :create), exam_mark: @invalid_attrs
      assert html_response(conn, 200) =~ "New Exam mark"
    end
  end

  describe "edit exam_mark" do
    setup [:create_exam_mark]

    test "renders form for editing chosen exam_mark", %{conn: conn, exam_mark: exam_mark} do
      conn = get conn, exam_mark_path(conn, :edit, exam_mark)
      assert html_response(conn, 200) =~ "Edit Exam mark"
    end
  end

  describe "update exam_mark" do
    setup [:create_exam_mark]

    test "redirects when data is valid", %{conn: conn, exam_mark: exam_mark} do
      conn = put conn, exam_mark_path(conn, :update, exam_mark), exam_mark: @update_attrs
      assert redirected_to(conn) == exam_mark_path(conn, :show, exam_mark)

      conn = get conn, exam_mark_path(conn, :show, exam_mark)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, exam_mark: exam_mark} do
      conn = put conn, exam_mark_path(conn, :update, exam_mark), exam_mark: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Exam mark"
    end
  end

  describe "delete exam_mark" do
    setup [:create_exam_mark]

    test "deletes chosen exam_mark", %{conn: conn, exam_mark: exam_mark} do
      conn = delete conn, exam_mark_path(conn, :delete, exam_mark)
      assert redirected_to(conn) == exam_mark_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, exam_mark_path(conn, :show, exam_mark)
      end
    end
  end

  defp create_exam_mark(_) do
    exam_mark = fixture(:exam_mark)
    {:ok, exam_mark: exam_mark}
  end
end
