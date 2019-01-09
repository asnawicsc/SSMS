defmodule SchoolWeb.RulesBreakControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{institution_id: 42, level: 42, remark: "some remark"}
  @update_attrs %{institution_id: 43, level: 43, remark: "some updated remark"}
  @invalid_attrs %{institution_id: nil, level: nil, remark: nil}

  def fixture(:rules_break) do
    {:ok, rules_break} = Affairs.create_rules_break(@create_attrs)
    rules_break
  end

  describe "index" do
    test "lists all rules_break", %{conn: conn} do
      conn = get conn, rules_break_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Rules break"
    end
  end

  describe "new rules_break" do
    test "renders form", %{conn: conn} do
      conn = get conn, rules_break_path(conn, :new)
      assert html_response(conn, 200) =~ "New Rules break"
    end
  end

  describe "create rules_break" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, rules_break_path(conn, :create), rules_break: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == rules_break_path(conn, :show, id)

      conn = get conn, rules_break_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Rules break"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, rules_break_path(conn, :create), rules_break: @invalid_attrs
      assert html_response(conn, 200) =~ "New Rules break"
    end
  end

  describe "edit rules_break" do
    setup [:create_rules_break]

    test "renders form for editing chosen rules_break", %{conn: conn, rules_break: rules_break} do
      conn = get conn, rules_break_path(conn, :edit, rules_break)
      assert html_response(conn, 200) =~ "Edit Rules break"
    end
  end

  describe "update rules_break" do
    setup [:create_rules_break]

    test "redirects when data is valid", %{conn: conn, rules_break: rules_break} do
      conn = put conn, rules_break_path(conn, :update, rules_break), rules_break: @update_attrs
      assert redirected_to(conn) == rules_break_path(conn, :show, rules_break)

      conn = get conn, rules_break_path(conn, :show, rules_break)
      assert html_response(conn, 200) =~ "some updated remark"
    end

    test "renders errors when data is invalid", %{conn: conn, rules_break: rules_break} do
      conn = put conn, rules_break_path(conn, :update, rules_break), rules_break: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Rules break"
    end
  end

  describe "delete rules_break" do
    setup [:create_rules_break]

    test "deletes chosen rules_break", %{conn: conn, rules_break: rules_break} do
      conn = delete conn, rules_break_path(conn, :delete, rules_break)
      assert redirected_to(conn) == rules_break_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, rules_break_path(conn, :show, rules_break)
      end
    end
  end

  defp create_rules_break(_) do
    rules_break = fixture(:rules_break)
    {:ok, rules_break: rules_break}
  end
end
