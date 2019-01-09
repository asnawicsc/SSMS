defmodule SchoolWeb.AssessmentMarkControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, institution_id: 42, rules_break_id: 42, semester_id: 42, standard_id: 42, student_id: 42, subject_id: 42}
  @update_attrs %{class_id: 43, institution_id: 43, rules_break_id: 43, semester_id: 43, standard_id: 43, student_id: 43, subject_id: 43}
  @invalid_attrs %{class_id: nil, institution_id: nil, rules_break_id: nil, semester_id: nil, standard_id: nil, student_id: nil, subject_id: nil}

  def fixture(:assessment_mark) do
    {:ok, assessment_mark} = Affairs.create_assessment_mark(@create_attrs)
    assessment_mark
  end

  describe "index" do
    test "lists all assessment_mark", %{conn: conn} do
      conn = get conn, assessment_mark_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Assessment mark"
    end
  end

  describe "new assessment_mark" do
    test "renders form", %{conn: conn} do
      conn = get conn, assessment_mark_path(conn, :new)
      assert html_response(conn, 200) =~ "New Assessment mark"
    end
  end

  describe "create assessment_mark" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, assessment_mark_path(conn, :create), assessment_mark: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == assessment_mark_path(conn, :show, id)

      conn = get conn, assessment_mark_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Assessment mark"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, assessment_mark_path(conn, :create), assessment_mark: @invalid_attrs
      assert html_response(conn, 200) =~ "New Assessment mark"
    end
  end

  describe "edit assessment_mark" do
    setup [:create_assessment_mark]

    test "renders form for editing chosen assessment_mark", %{conn: conn, assessment_mark: assessment_mark} do
      conn = get conn, assessment_mark_path(conn, :edit, assessment_mark)
      assert html_response(conn, 200) =~ "Edit Assessment mark"
    end
  end

  describe "update assessment_mark" do
    setup [:create_assessment_mark]

    test "redirects when data is valid", %{conn: conn, assessment_mark: assessment_mark} do
      conn = put conn, assessment_mark_path(conn, :update, assessment_mark), assessment_mark: @update_attrs
      assert redirected_to(conn) == assessment_mark_path(conn, :show, assessment_mark)

      conn = get conn, assessment_mark_path(conn, :show, assessment_mark)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, assessment_mark: assessment_mark} do
      conn = put conn, assessment_mark_path(conn, :update, assessment_mark), assessment_mark: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Assessment mark"
    end
  end

  describe "delete assessment_mark" do
    setup [:create_assessment_mark]

    test "deletes chosen assessment_mark", %{conn: conn, assessment_mark: assessment_mark} do
      conn = delete conn, assessment_mark_path(conn, :delete, assessment_mark)
      assert redirected_to(conn) == assessment_mark_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, assessment_mark_path(conn, :show, assessment_mark)
      end
    end
  end

  defp create_assessment_mark(_) do
    assessment_mark = fixture(:assessment_mark)
    {:ok, assessment_mark: assessment_mark}
  end
end
