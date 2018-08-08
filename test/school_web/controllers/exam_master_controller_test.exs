defmodule SchoolWeb.ExamMasterControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{level_id: 42, name: "some name", semester_id: 42, year: "some year"}
  @update_attrs %{level_id: 43, name: "some updated name", semester_id: 43, year: "some updated year"}
  @invalid_attrs %{level_id: nil, name: nil, semester_id: nil, year: nil}

  def fixture(:exam_master) do
    {:ok, exam_master} = Affairs.create_exam_master(@create_attrs)
    exam_master
  end

  describe "index" do
    test "lists all exam_master", %{conn: conn} do
      conn = get conn, exam_master_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Exam master"
    end
  end

  describe "new exam_master" do
    test "renders form", %{conn: conn} do
      conn = get conn, exam_master_path(conn, :new)
      assert html_response(conn, 200) =~ "New Exam master"
    end
  end

  describe "create exam_master" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, exam_master_path(conn, :create), exam_master: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == exam_master_path(conn, :show, id)

      conn = get conn, exam_master_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Exam master"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, exam_master_path(conn, :create), exam_master: @invalid_attrs
      assert html_response(conn, 200) =~ "New Exam master"
    end
  end

  describe "edit exam_master" do
    setup [:create_exam_master]

    test "renders form for editing chosen exam_master", %{conn: conn, exam_master: exam_master} do
      conn = get conn, exam_master_path(conn, :edit, exam_master)
      assert html_response(conn, 200) =~ "Edit Exam master"
    end
  end

  describe "update exam_master" do
    setup [:create_exam_master]

    test "redirects when data is valid", %{conn: conn, exam_master: exam_master} do
      conn = put conn, exam_master_path(conn, :update, exam_master), exam_master: @update_attrs
      assert redirected_to(conn) == exam_master_path(conn, :show, exam_master)

      conn = get conn, exam_master_path(conn, :show, exam_master)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, exam_master: exam_master} do
      conn = put conn, exam_master_path(conn, :update, exam_master), exam_master: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Exam master"
    end
  end

  describe "delete exam_master" do
    setup [:create_exam_master]

    test "deletes chosen exam_master", %{conn: conn, exam_master: exam_master} do
      conn = delete conn, exam_master_path(conn, :delete, exam_master)
      assert redirected_to(conn) == exam_master_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, exam_master_path(conn, :show, exam_master)
      end
    end
  end

  defp create_exam_master(_) do
    exam_master = fixture(:exam_master)
    {:ok, exam_master: exam_master}
  end
end
