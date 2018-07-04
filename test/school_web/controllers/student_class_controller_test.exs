defmodule SchoolWeb.StudentClassControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, institute_id: 42, level_id: 42, semester_id: 42, sudent_id: 42}
  @update_attrs %{class_id: 43, institute_id: 43, level_id: 43, semester_id: 43, sudent_id: 43}
  @invalid_attrs %{class_id: nil, institute_id: nil, level_id: nil, semester_id: nil, sudent_id: nil}

  def fixture(:student_class) do
    {:ok, student_class} = Affairs.create_student_class(@create_attrs)
    student_class
  end

  describe "index" do
    test "lists all student_classes", %{conn: conn} do
      conn = get conn, student_class_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Student classes"
    end
  end

  describe "new student_class" do
    test "renders form", %{conn: conn} do
      conn = get conn, student_class_path(conn, :new)
      assert html_response(conn, 200) =~ "New Student class"
    end
  end

  describe "create student_class" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, student_class_path(conn, :create), student_class: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == student_class_path(conn, :show, id)

      conn = get conn, student_class_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Student class"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, student_class_path(conn, :create), student_class: @invalid_attrs
      assert html_response(conn, 200) =~ "New Student class"
    end
  end

  describe "edit student_class" do
    setup [:create_student_class]

    test "renders form for editing chosen student_class", %{conn: conn, student_class: student_class} do
      conn = get conn, student_class_path(conn, :edit, student_class)
      assert html_response(conn, 200) =~ "Edit Student class"
    end
  end

  describe "update student_class" do
    setup [:create_student_class]

    test "redirects when data is valid", %{conn: conn, student_class: student_class} do
      conn = put conn, student_class_path(conn, :update, student_class), student_class: @update_attrs
      assert redirected_to(conn) == student_class_path(conn, :show, student_class)

      conn = get conn, student_class_path(conn, :show, student_class)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, student_class: student_class} do
      conn = put conn, student_class_path(conn, :update, student_class), student_class: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Student class"
    end
  end

  describe "delete student_class" do
    setup [:create_student_class]

    test "deletes chosen student_class", %{conn: conn, student_class: student_class} do
      conn = delete conn, student_class_path(conn, :delete, student_class)
      assert redirected_to(conn) == student_class_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, student_class_path(conn, :show, student_class)
      end
    end
  end

  defp create_student_class(_) do
    student_class = fixture(:student_class)
    {:ok, student_class: student_class}
  end
end
