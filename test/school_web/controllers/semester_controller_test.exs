defmodule SchoolWeb.SemesterControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{end_date: ~D[2010-04-17], holiday_end: ~D[2010-04-17], holiday_start: ~D[2010-04-17], school_days: 42, start_date: ~D[2010-04-17]}
  @update_attrs %{end_date: ~D[2011-05-18], holiday_end: ~D[2011-05-18], holiday_start: ~D[2011-05-18], school_days: 43, start_date: ~D[2011-05-18]}
  @invalid_attrs %{end_date: nil, holiday_end: nil, holiday_start: nil, school_days: nil, start_date: nil}

  def fixture(:semester) do
    {:ok, semester} = Affairs.create_semester(@create_attrs)
    semester
  end

  describe "index" do
    test "lists all semesters", %{conn: conn} do
      conn = get conn, semester_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Semesters"
    end
  end

  describe "new semester" do
    test "renders form", %{conn: conn} do
      conn = get conn, semester_path(conn, :new)
      assert html_response(conn, 200) =~ "New Semester"
    end
  end

  describe "create semester" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, semester_path(conn, :create), semester: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == semester_path(conn, :show, id)

      conn = get conn, semester_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Semester"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, semester_path(conn, :create), semester: @invalid_attrs
      assert html_response(conn, 200) =~ "New Semester"
    end
  end

  describe "edit semester" do
    setup [:create_semester]

    test "renders form for editing chosen semester", %{conn: conn, semester: semester} do
      conn = get conn, semester_path(conn, :edit, semester)
      assert html_response(conn, 200) =~ "Edit Semester"
    end
  end

  describe "update semester" do
    setup [:create_semester]

    test "redirects when data is valid", %{conn: conn, semester: semester} do
      conn = put conn, semester_path(conn, :update, semester), semester: @update_attrs
      assert redirected_to(conn) == semester_path(conn, :show, semester)

      conn = get conn, semester_path(conn, :show, semester)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, semester: semester} do
      conn = put conn, semester_path(conn, :update, semester), semester: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Semester"
    end
  end

  describe "delete semester" do
    setup [:create_semester]

    test "deletes chosen semester", %{conn: conn, semester: semester} do
      conn = delete conn, semester_path(conn, :delete, semester)
      assert redirected_to(conn) == semester_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, semester_path(conn, :show, semester)
      end
    end
  end

  defp create_semester(_) do
    semester = fixture(:semester)
    {:ok, semester: semester}
  end
end
