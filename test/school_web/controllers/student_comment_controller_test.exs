defmodule SchoolWeb.StudentCommentControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, comment1: "some comment1", comment2: "some comment2", comment3: "some comment3", semester_id: 42, student_id: 42, year: "some year"}
  @update_attrs %{class_id: 43, comment1: "some updated comment1", comment2: "some updated comment2", comment3: "some updated comment3", semester_id: 43, student_id: 43, year: "some updated year"}
  @invalid_attrs %{class_id: nil, comment1: nil, comment2: nil, comment3: nil, semester_id: nil, student_id: nil, year: nil}

  def fixture(:student_comment) do
    {:ok, student_comment} = Affairs.create_student_comment(@create_attrs)
    student_comment
  end

  describe "index" do
    test "lists all student_comment", %{conn: conn} do
      conn = get conn, student_comment_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Student comment"
    end
  end

  describe "new student_comment" do
    test "renders form", %{conn: conn} do
      conn = get conn, student_comment_path(conn, :new)
      assert html_response(conn, 200) =~ "New Student comment"
    end
  end

  describe "create student_comment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, student_comment_path(conn, :create), student_comment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == student_comment_path(conn, :show, id)

      conn = get conn, student_comment_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Student comment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, student_comment_path(conn, :create), student_comment: @invalid_attrs
      assert html_response(conn, 200) =~ "New Student comment"
    end
  end

  describe "edit student_comment" do
    setup [:create_student_comment]

    test "renders form for editing chosen student_comment", %{conn: conn, student_comment: student_comment} do
      conn = get conn, student_comment_path(conn, :edit, student_comment)
      assert html_response(conn, 200) =~ "Edit Student comment"
    end
  end

  describe "update student_comment" do
    setup [:create_student_comment]

    test "redirects when data is valid", %{conn: conn, student_comment: student_comment} do
      conn = put conn, student_comment_path(conn, :update, student_comment), student_comment: @update_attrs
      assert redirected_to(conn) == student_comment_path(conn, :show, student_comment)

      conn = get conn, student_comment_path(conn, :show, student_comment)
      assert html_response(conn, 200) =~ "some updated comment1"
    end

    test "renders errors when data is invalid", %{conn: conn, student_comment: student_comment} do
      conn = put conn, student_comment_path(conn, :update, student_comment), student_comment: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Student comment"
    end
  end

  describe "delete student_comment" do
    setup [:create_student_comment]

    test "deletes chosen student_comment", %{conn: conn, student_comment: student_comment} do
      conn = delete conn, student_comment_path(conn, :delete, student_comment)
      assert redirected_to(conn) == student_comment_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, student_comment_path(conn, :show, student_comment)
      end
    end
  end

  defp create_student_comment(_) do
    student_comment = fixture(:student_comment)
    {:ok, student_comment: student_comment}
  end
end
