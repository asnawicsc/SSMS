defmodule SchoolWeb.StudentMarkNilamControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{institution_id: 42, student_id: 42, total_book_integer: "some total_book_integer", year: 42}
  @update_attrs %{institution_id: 43, student_id: 43, total_book_integer: "some updated total_book_integer", year: 43}
  @invalid_attrs %{institution_id: nil, student_id: nil, total_book_integer: nil, year: nil}

  def fixture(:student_mark_nilam) do
    {:ok, student_mark_nilam} = Affairs.create_student_mark_nilam(@create_attrs)
    student_mark_nilam
  end

  describe "index" do
    test "lists all student_mark_nilam", %{conn: conn} do
      conn = get conn, student_mark_nilam_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Student mark nilam"
    end
  end

  describe "new student_mark_nilam" do
    test "renders form", %{conn: conn} do
      conn = get conn, student_mark_nilam_path(conn, :new)
      assert html_response(conn, 200) =~ "New Student mark nilam"
    end
  end

  describe "create student_mark_nilam" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, student_mark_nilam_path(conn, :create), student_mark_nilam: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == student_mark_nilam_path(conn, :show, id)

      conn = get conn, student_mark_nilam_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Student mark nilam"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, student_mark_nilam_path(conn, :create), student_mark_nilam: @invalid_attrs
      assert html_response(conn, 200) =~ "New Student mark nilam"
    end
  end

  describe "edit student_mark_nilam" do
    setup [:create_student_mark_nilam]

    test "renders form for editing chosen student_mark_nilam", %{conn: conn, student_mark_nilam: student_mark_nilam} do
      conn = get conn, student_mark_nilam_path(conn, :edit, student_mark_nilam)
      assert html_response(conn, 200) =~ "Edit Student mark nilam"
    end
  end

  describe "update student_mark_nilam" do
    setup [:create_student_mark_nilam]

    test "redirects when data is valid", %{conn: conn, student_mark_nilam: student_mark_nilam} do
      conn = put conn, student_mark_nilam_path(conn, :update, student_mark_nilam), student_mark_nilam: @update_attrs
      assert redirected_to(conn) == student_mark_nilam_path(conn, :show, student_mark_nilam)

      conn = get conn, student_mark_nilam_path(conn, :show, student_mark_nilam)
      assert html_response(conn, 200) =~ "some updated total_book_integer"
    end

    test "renders errors when data is invalid", %{conn: conn, student_mark_nilam: student_mark_nilam} do
      conn = put conn, student_mark_nilam_path(conn, :update, student_mark_nilam), student_mark_nilam: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Student mark nilam"
    end
  end

  describe "delete student_mark_nilam" do
    setup [:create_student_mark_nilam]

    test "deletes chosen student_mark_nilam", %{conn: conn, student_mark_nilam: student_mark_nilam} do
      conn = delete conn, student_mark_nilam_path(conn, :delete, student_mark_nilam)
      assert redirected_to(conn) == student_mark_nilam_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, student_mark_nilam_path(conn, :show, student_mark_nilam)
      end
    end
  end

  defp create_student_mark_nilam(_) do
    student_mark_nilam = fixture(:student_mark_nilam)
    {:ok, student_mark_nilam: student_mark_nilam}
  end
end
