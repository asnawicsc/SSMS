defmodule SchoolWeb.HistoryExamControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_name: "some class_name", exam_class_rank: 42, exam_grade: "some exam_grade", exam_name: "some exam_name", exam_standard_rank: 42, institution_id: 42, semester_id: 42, student_name: "some student_name", student_no: 42, subject_code: "some subject_code", subject_mark: "120.5", subject_name: "some subject_name"}
  @update_attrs %{class_name: "some updated class_name", exam_class_rank: 43, exam_grade: "some updated exam_grade", exam_name: "some updated exam_name", exam_standard_rank: 43, institution_id: 43, semester_id: 43, student_name: "some updated student_name", student_no: 43, subject_code: "some updated subject_code", subject_mark: "456.7", subject_name: "some updated subject_name"}
  @invalid_attrs %{class_name: nil, exam_class_rank: nil, exam_grade: nil, exam_name: nil, exam_standard_rank: nil, institution_id: nil, semester_id: nil, student_name: nil, student_no: nil, subject_code: nil, subject_mark: nil, subject_name: nil}

  def fixture(:history_exam) do
    {:ok, history_exam} = Affairs.create_history_exam(@create_attrs)
    history_exam
  end

  describe "index" do
    test "lists all history_exam", %{conn: conn} do
      conn = get conn, history_exam_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing History exam"
    end
  end

  describe "new history_exam" do
    test "renders form", %{conn: conn} do
      conn = get conn, history_exam_path(conn, :new)
      assert html_response(conn, 200) =~ "New History exam"
    end
  end

  describe "create history_exam" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, history_exam_path(conn, :create), history_exam: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == history_exam_path(conn, :show, id)

      conn = get conn, history_exam_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show History exam"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, history_exam_path(conn, :create), history_exam: @invalid_attrs
      assert html_response(conn, 200) =~ "New History exam"
    end
  end

  describe "edit history_exam" do
    setup [:create_history_exam]

    test "renders form for editing chosen history_exam", %{conn: conn, history_exam: history_exam} do
      conn = get conn, history_exam_path(conn, :edit, history_exam)
      assert html_response(conn, 200) =~ "Edit History exam"
    end
  end

  describe "update history_exam" do
    setup [:create_history_exam]

    test "redirects when data is valid", %{conn: conn, history_exam: history_exam} do
      conn = put conn, history_exam_path(conn, :update, history_exam), history_exam: @update_attrs
      assert redirected_to(conn) == history_exam_path(conn, :show, history_exam)

      conn = get conn, history_exam_path(conn, :show, history_exam)
      assert html_response(conn, 200) =~ "some updated class_name"
    end

    test "renders errors when data is invalid", %{conn: conn, history_exam: history_exam} do
      conn = put conn, history_exam_path(conn, :update, history_exam), history_exam: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit History exam"
    end
  end

  describe "delete history_exam" do
    setup [:create_history_exam]

    test "deletes chosen history_exam", %{conn: conn, history_exam: history_exam} do
      conn = delete conn, history_exam_path(conn, :delete, history_exam)
      assert redirected_to(conn) == history_exam_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, history_exam_path(conn, :show, history_exam)
      end
    end
  end

  defp create_history_exam(_) do
    history_exam = fixture(:history_exam)
    {:ok, history_exam: history_exam}
  end
end
