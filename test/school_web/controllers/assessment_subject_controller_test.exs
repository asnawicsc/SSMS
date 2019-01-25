defmodule SchoolWeb.AssessmentSubjectControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{institution_id: 42, semester_id: 42, standard_id: 42, subject_id: 42}
  @update_attrs %{institution_id: 43, semester_id: 43, standard_id: 43, subject_id: 43}
  @invalid_attrs %{institution_id: nil, semester_id: nil, standard_id: nil, subject_id: nil}

  def fixture(:assessment_subject) do
    {:ok, assessment_subject} = Affairs.create_assessment_subject(@create_attrs)
    assessment_subject
  end

  describe "index" do
    test "lists all assessment_subject", %{conn: conn} do
      conn = get conn, assessment_subject_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Assessment subject"
    end
  end

  describe "new assessment_subject" do
    test "renders form", %{conn: conn} do
      conn = get conn, assessment_subject_path(conn, :new)
      assert html_response(conn, 200) =~ "New Assessment subject"
    end
  end

  describe "create assessment_subject" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, assessment_subject_path(conn, :create), assessment_subject: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == assessment_subject_path(conn, :show, id)

      conn = get conn, assessment_subject_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Assessment subject"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, assessment_subject_path(conn, :create), assessment_subject: @invalid_attrs
      assert html_response(conn, 200) =~ "New Assessment subject"
    end
  end

  describe "edit assessment_subject" do
    setup [:create_assessment_subject]

    test "renders form for editing chosen assessment_subject", %{conn: conn, assessment_subject: assessment_subject} do
      conn = get conn, assessment_subject_path(conn, :edit, assessment_subject)
      assert html_response(conn, 200) =~ "Edit Assessment subject"
    end
  end

  describe "update assessment_subject" do
    setup [:create_assessment_subject]

    test "redirects when data is valid", %{conn: conn, assessment_subject: assessment_subject} do
      conn = put conn, assessment_subject_path(conn, :update, assessment_subject), assessment_subject: @update_attrs
      assert redirected_to(conn) == assessment_subject_path(conn, :show, assessment_subject)

      conn = get conn, assessment_subject_path(conn, :show, assessment_subject)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, assessment_subject: assessment_subject} do
      conn = put conn, assessment_subject_path(conn, :update, assessment_subject), assessment_subject: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Assessment subject"
    end
  end

  describe "delete assessment_subject" do
    setup [:create_assessment_subject]

    test "deletes chosen assessment_subject", %{conn: conn, assessment_subject: assessment_subject} do
      conn = delete conn, assessment_subject_path(conn, :delete, assessment_subject)
      assert redirected_to(conn) == assessment_subject_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, assessment_subject_path(conn, :show, assessment_subject)
      end
    end
  end

  defp create_assessment_subject(_) do
    assessment_subject = fixture(:assessment_subject)
    {:ok, assessment_subject: assessment_subject}
  end
end
