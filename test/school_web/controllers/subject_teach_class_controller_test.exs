defmodule SchoolWeb.SubjectTeachClassControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, standard_id: 42, subject_id: 42, teacher_id: 42}
  @update_attrs %{class_id: 43, standard_id: 43, subject_id: 43, teacher_id: 43}
  @invalid_attrs %{class_id: nil, standard_id: nil, subject_id: nil, teacher_id: nil}

  def fixture(:subject_teach_class) do
    {:ok, subject_teach_class} = Affairs.create_subject_teach_class(@create_attrs)
    subject_teach_class
  end

  describe "index" do
    test "lists all subject_teach_class", %{conn: conn} do
      conn = get conn, subject_teach_class_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Subject teach class"
    end
  end

  describe "new subject_teach_class" do
    test "renders form", %{conn: conn} do
      conn = get conn, subject_teach_class_path(conn, :new)
      assert html_response(conn, 200) =~ "New Subject teach class"
    end
  end

  describe "create subject_teach_class" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, subject_teach_class_path(conn, :create), subject_teach_class: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == subject_teach_class_path(conn, :show, id)

      conn = get conn, subject_teach_class_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Subject teach class"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, subject_teach_class_path(conn, :create), subject_teach_class: @invalid_attrs
      assert html_response(conn, 200) =~ "New Subject teach class"
    end
  end

  describe "edit subject_teach_class" do
    setup [:create_subject_teach_class]

    test "renders form for editing chosen subject_teach_class", %{conn: conn, subject_teach_class: subject_teach_class} do
      conn = get conn, subject_teach_class_path(conn, :edit, subject_teach_class)
      assert html_response(conn, 200) =~ "Edit Subject teach class"
    end
  end

  describe "update subject_teach_class" do
    setup [:create_subject_teach_class]

    test "redirects when data is valid", %{conn: conn, subject_teach_class: subject_teach_class} do
      conn = put conn, subject_teach_class_path(conn, :update, subject_teach_class), subject_teach_class: @update_attrs
      assert redirected_to(conn) == subject_teach_class_path(conn, :show, subject_teach_class)

      conn = get conn, subject_teach_class_path(conn, :show, subject_teach_class)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, subject_teach_class: subject_teach_class} do
      conn = put conn, subject_teach_class_path(conn, :update, subject_teach_class), subject_teach_class: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Subject teach class"
    end
  end

  describe "delete subject_teach_class" do
    setup [:create_subject_teach_class]

    test "deletes chosen subject_teach_class", %{conn: conn, subject_teach_class: subject_teach_class} do
      conn = delete conn, subject_teach_class_path(conn, :delete, subject_teach_class)
      assert redirected_to(conn) == subject_teach_class_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, subject_teach_class_path(conn, :show, subject_teach_class)
      end
    end
  end

  defp create_subject_teach_class(_) do
    subject_teach_class = fixture(:subject_teach_class)
    {:ok, subject_teach_class: subject_teach_class}
  end
end
