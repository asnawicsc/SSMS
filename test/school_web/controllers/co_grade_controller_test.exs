defmodule SchoolWeb.CoGradeControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{gpa: "120.5", max: 42, min: 42, name: "some name"}
  @update_attrs %{gpa: "456.7", max: 43, min: 43, name: "some updated name"}
  @invalid_attrs %{gpa: nil, max: nil, min: nil, name: nil}

  def fixture(:co_grade) do
    {:ok, co_grade} = Affairs.create_co_grade(@create_attrs)
    co_grade
  end

  describe "index" do
    test "lists all co_grade", %{conn: conn} do
      conn = get conn, co_grade_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Co grade"
    end
  end

  describe "new co_grade" do
    test "renders form", %{conn: conn} do
      conn = get conn, co_grade_path(conn, :new)
      assert html_response(conn, 200) =~ "New Co grade"
    end
  end

  describe "create co_grade" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, co_grade_path(conn, :create), co_grade: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == co_grade_path(conn, :show, id)

      conn = get conn, co_grade_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Co grade"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, co_grade_path(conn, :create), co_grade: @invalid_attrs
      assert html_response(conn, 200) =~ "New Co grade"
    end
  end

  describe "edit co_grade" do
    setup [:create_co_grade]

    test "renders form for editing chosen co_grade", %{conn: conn, co_grade: co_grade} do
      conn = get conn, co_grade_path(conn, :edit, co_grade)
      assert html_response(conn, 200) =~ "Edit Co grade"
    end
  end

  describe "update co_grade" do
    setup [:create_co_grade]

    test "redirects when data is valid", %{conn: conn, co_grade: co_grade} do
      conn = put conn, co_grade_path(conn, :update, co_grade), co_grade: @update_attrs
      assert redirected_to(conn) == co_grade_path(conn, :show, co_grade)

      conn = get conn, co_grade_path(conn, :show, co_grade)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, co_grade: co_grade} do
      conn = put conn, co_grade_path(conn, :update, co_grade), co_grade: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Co grade"
    end
  end

  describe "delete co_grade" do
    setup [:create_co_grade]

    test "deletes chosen co_grade", %{conn: conn, co_grade: co_grade} do
      conn = delete conn, co_grade_path(conn, :delete, co_grade)
      assert redirected_to(conn) == co_grade_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, co_grade_path(conn, :show, co_grade)
      end
    end
  end

  defp create_co_grade(_) do
    co_grade = fixture(:co_grade)
    {:ok, co_grade: co_grade}
  end
end
