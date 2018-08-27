defmodule SchoolWeb.HeadCountControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{class_id: 42, student_id: 42, subject_id: 42, targer_mark: 42}
  @update_attrs %{class_id: 43, student_id: 43, subject_id: 43, targer_mark: 43}
  @invalid_attrs %{class_id: nil, student_id: nil, subject_id: nil, targer_mark: nil}

  def fixture(:head_count) do
    {:ok, head_count} = Affairs.create_head_count(@create_attrs)
    head_count
  end

  describe "index" do
    test "lists all head_counts", %{conn: conn} do
      conn = get conn, head_count_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Head counts"
    end
  end

  describe "new head_count" do
    test "renders form", %{conn: conn} do
      conn = get conn, head_count_path(conn, :new)
      assert html_response(conn, 200) =~ "New Head count"
    end
  end

  describe "create head_count" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, head_count_path(conn, :create), head_count: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == head_count_path(conn, :show, id)

      conn = get conn, head_count_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Head count"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, head_count_path(conn, :create), head_count: @invalid_attrs
      assert html_response(conn, 200) =~ "New Head count"
    end
  end

  describe "edit head_count" do
    setup [:create_head_count]

    test "renders form for editing chosen head_count", %{conn: conn, head_count: head_count} do
      conn = get conn, head_count_path(conn, :edit, head_count)
      assert html_response(conn, 200) =~ "Edit Head count"
    end
  end

  describe "update head_count" do
    setup [:create_head_count]

    test "redirects when data is valid", %{conn: conn, head_count: head_count} do
      conn = put conn, head_count_path(conn, :update, head_count), head_count: @update_attrs
      assert redirected_to(conn) == head_count_path(conn, :show, head_count)

      conn = get conn, head_count_path(conn, :show, head_count)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, head_count: head_count} do
      conn = put conn, head_count_path(conn, :update, head_count), head_count: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Head count"
    end
  end

  describe "delete head_count" do
    setup [:create_head_count]

    test "deletes chosen head_count", %{conn: conn, head_count: head_count} do
      conn = delete conn, head_count_path(conn, :delete, head_count)
      assert redirected_to(conn) == head_count_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, head_count_path(conn, :show, head_count)
      end
    end
  end

  defp create_head_count(_) do
    head_count = fixture(:head_count)
    {:ok, head_count: head_count}
  end
end
