defmodule SchoolWeb.AbsentHistoryControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{absent_date: "some absent_date", absent_type: "some absent_type", chinese_name: "some chinese_name", student_class: "some student_class", student_name: "some student_name", student_no: 42, year: 42}
  @update_attrs %{absent_date: "some updated absent_date", absent_type: "some updated absent_type", chinese_name: "some updated chinese_name", student_class: "some updated student_class", student_name: "some updated student_name", student_no: 43, year: 43}
  @invalid_attrs %{absent_date: nil, absent_type: nil, chinese_name: nil, student_class: nil, student_name: nil, student_no: nil, year: nil}

  def fixture(:absent_history) do
    {:ok, absent_history} = Affairs.create_absent_history(@create_attrs)
    absent_history
  end

  describe "index" do
    test "lists all absent_history", %{conn: conn} do
      conn = get conn, absent_history_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Absent history"
    end
  end

  describe "new absent_history" do
    test "renders form", %{conn: conn} do
      conn = get conn, absent_history_path(conn, :new)
      assert html_response(conn, 200) =~ "New Absent history"
    end
  end

  describe "create absent_history" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, absent_history_path(conn, :create), absent_history: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == absent_history_path(conn, :show, id)

      conn = get conn, absent_history_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Absent history"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, absent_history_path(conn, :create), absent_history: @invalid_attrs
      assert html_response(conn, 200) =~ "New Absent history"
    end
  end

  describe "edit absent_history" do
    setup [:create_absent_history]

    test "renders form for editing chosen absent_history", %{conn: conn, absent_history: absent_history} do
      conn = get conn, absent_history_path(conn, :edit, absent_history)
      assert html_response(conn, 200) =~ "Edit Absent history"
    end
  end

  describe "update absent_history" do
    setup [:create_absent_history]

    test "redirects when data is valid", %{conn: conn, absent_history: absent_history} do
      conn = put conn, absent_history_path(conn, :update, absent_history), absent_history: @update_attrs
      assert redirected_to(conn) == absent_history_path(conn, :show, absent_history)

      conn = get conn, absent_history_path(conn, :show, absent_history)
      assert html_response(conn, 200) =~ "some updated absent_date"
    end

    test "renders errors when data is invalid", %{conn: conn, absent_history: absent_history} do
      conn = put conn, absent_history_path(conn, :update, absent_history), absent_history: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Absent history"
    end
  end

  describe "delete absent_history" do
    setup [:create_absent_history]

    test "deletes chosen absent_history", %{conn: conn, absent_history: absent_history} do
      conn = delete conn, absent_history_path(conn, :delete, absent_history)
      assert redirected_to(conn) == absent_history_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, absent_history_path(conn, :show, absent_history)
      end
    end
  end

  defp create_absent_history(_) do
    absent_history = fixture(:absent_history)
    {:ok, absent_history: absent_history}
  end
end
