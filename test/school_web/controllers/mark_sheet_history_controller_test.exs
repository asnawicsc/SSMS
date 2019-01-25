defmodule SchoolWeb.MarkSheetHistoryControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{cdesc: "some cdesc", class: "some class", cname: "some cname", description: "some description", institution_id: 42, name: "some name", s1g: "some s1g", s1m: "some s1m", s2g: "some s2g", s2m: "some s2m", s3g: "some s3g", stuid: "some stuid", subject: "some subject", t1g: "some t1g", t1m: "some t1m", t2g: "some t2g", t2m: "some t2m", t3g: "some t3g", t3m: "some t3m", t4g: "some t4g", t4m: "some t4m", t5g: "some t5g", t5m: "some t5m", t6g: "some t6g", t6m: "some t6m", year: "some year"}
  @update_attrs %{cdesc: "some updated cdesc", class: "some updated class", cname: "some updated cname", description: "some updated description", institution_id: 43, name: "some updated name", s1g: "some updated s1g", s1m: "some updated s1m", s2g: "some updated s2g", s2m: "some updated s2m", s3g: "some updated s3g", stuid: "some updated stuid", subject: "some updated subject", t1g: "some updated t1g", t1m: "some updated t1m", t2g: "some updated t2g", t2m: "some updated t2m", t3g: "some updated t3g", t3m: "some updated t3m", t4g: "some updated t4g", t4m: "some updated t4m", t5g: "some updated t5g", t5m: "some updated t5m", t6g: "some updated t6g", t6m: "some updated t6m", year: "some updated year"}
  @invalid_attrs %{cdesc: nil, class: nil, cname: nil, description: nil, institution_id: nil, name: nil, s1g: nil, s1m: nil, s2g: nil, s2m: nil, s3g: nil, stuid: nil, subject: nil, t1g: nil, t1m: nil, t2g: nil, t2m: nil, t3g: nil, t3m: nil, t4g: nil, t4m: nil, t5g: nil, t5m: nil, t6g: nil, t6m: nil, year: nil}

  def fixture(:mark_sheet_history) do
    {:ok, mark_sheet_history} = Affairs.create_mark_sheet_history(@create_attrs)
    mark_sheet_history
  end

  describe "index" do
    test "lists all mark_sheet_history", %{conn: conn} do
      conn = get conn, mark_sheet_history_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Mark sheet history"
    end
  end

  describe "new mark_sheet_history" do
    test "renders form", %{conn: conn} do
      conn = get conn, mark_sheet_history_path(conn, :new)
      assert html_response(conn, 200) =~ "New Mark sheet history"
    end
  end

  describe "create mark_sheet_history" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, mark_sheet_history_path(conn, :create), mark_sheet_history: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == mark_sheet_history_path(conn, :show, id)

      conn = get conn, mark_sheet_history_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Mark sheet history"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, mark_sheet_history_path(conn, :create), mark_sheet_history: @invalid_attrs
      assert html_response(conn, 200) =~ "New Mark sheet history"
    end
  end

  describe "edit mark_sheet_history" do
    setup [:create_mark_sheet_history]

    test "renders form for editing chosen mark_sheet_history", %{conn: conn, mark_sheet_history: mark_sheet_history} do
      conn = get conn, mark_sheet_history_path(conn, :edit, mark_sheet_history)
      assert html_response(conn, 200) =~ "Edit Mark sheet history"
    end
  end

  describe "update mark_sheet_history" do
    setup [:create_mark_sheet_history]

    test "redirects when data is valid", %{conn: conn, mark_sheet_history: mark_sheet_history} do
      conn = put conn, mark_sheet_history_path(conn, :update, mark_sheet_history), mark_sheet_history: @update_attrs
      assert redirected_to(conn) == mark_sheet_history_path(conn, :show, mark_sheet_history)

      conn = get conn, mark_sheet_history_path(conn, :show, mark_sheet_history)
      assert html_response(conn, 200) =~ "some updated cdesc"
    end

    test "renders errors when data is invalid", %{conn: conn, mark_sheet_history: mark_sheet_history} do
      conn = put conn, mark_sheet_history_path(conn, :update, mark_sheet_history), mark_sheet_history: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Mark sheet history"
    end
  end

  describe "delete mark_sheet_history" do
    setup [:create_mark_sheet_history]

    test "deletes chosen mark_sheet_history", %{conn: conn, mark_sheet_history: mark_sheet_history} do
      conn = delete conn, mark_sheet_history_path(conn, :delete, mark_sheet_history)
      assert redirected_to(conn) == mark_sheet_history_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, mark_sheet_history_path(conn, :show, mark_sheet_history)
      end
    end
  end

  defp create_mark_sheet_history(_) do
    mark_sheet_history = fixture(:mark_sheet_history)
    {:ok, mark_sheet_history: mark_sheet_history}
  end
end
