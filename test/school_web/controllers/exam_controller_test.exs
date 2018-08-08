defmodule SchoolWeb.ExamControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{exam_master_id: 42, subject_id: 42}
  @update_attrs %{exam_master_id: 43, subject_id: 43}
  @invalid_attrs %{exam_master_id: nil, subject_id: nil}

  def fixture(:exam) do
    {:ok, exam} = Affairs.create_exam(@create_attrs)
    exam
  end

  describe "index" do
    test "lists all exam", %{conn: conn} do
      conn = get conn, exam_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Exam"
    end
  end

  describe "new exam" do
    test "renders form", %{conn: conn} do
      conn = get conn, exam_path(conn, :new)
      assert html_response(conn, 200) =~ "New Exam"
    end
  end

  describe "create exam" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, exam_path(conn, :create), exam: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == exam_path(conn, :show, id)

      conn = get conn, exam_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Exam"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, exam_path(conn, :create), exam: @invalid_attrs
      assert html_response(conn, 200) =~ "New Exam"
    end
  end

  describe "edit exam" do
    setup [:create_exam]

    test "renders form for editing chosen exam", %{conn: conn, exam: exam} do
      conn = get conn, exam_path(conn, :edit, exam)
      assert html_response(conn, 200) =~ "Edit Exam"
    end
  end

  describe "update exam" do
    setup [:create_exam]

    test "redirects when data is valid", %{conn: conn, exam: exam} do
      conn = put conn, exam_path(conn, :update, exam), exam: @update_attrs
      assert redirected_to(conn) == exam_path(conn, :show, exam)

      conn = get conn, exam_path(conn, :show, exam)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, exam: exam} do
      conn = put conn, exam_path(conn, :update, exam), exam: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Exam"
    end
  end

  describe "delete exam" do
    setup [:create_exam]

    test "deletes chosen exam", %{conn: conn, exam: exam} do
      conn = delete conn, exam_path(conn, :delete, exam)
      assert redirected_to(conn) == exam_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, exam_path(conn, :show, exam)
      end
    end
  end

  defp create_exam(_) do
    exam = fixture(:exam)
    {:ok, exam: exam}
  end
end
