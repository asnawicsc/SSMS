defmodule SchoolWeb.MarkSheetTempControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{cdesc: "some cdesc", class: "some class", cname: "some cname", description: "some description", institution_id: 42, name: "some name", s1g: "some s1g", s1m: "some s1m", s2g: "some s2g", s2m: "some s2m", s3g: "some s3g", s3m: "some s3m", semester: "some semester", stuid: "some stuid", subject: "some subject", year: "some year"}
  @update_attrs %{cdesc: "some updated cdesc", class: "some updated class", cname: "some updated cname", description: "some updated description", institution_id: 43, name: "some updated name", s1g: "some updated s1g", s1m: "some updated s1m", s2g: "some updated s2g", s2m: "some updated s2m", s3g: "some updated s3g", s3m: "some updated s3m", semester: "some updated semester", stuid: "some updated stuid", subject: "some updated subject", year: "some updated year"}
  @invalid_attrs %{cdesc: nil, class: nil, cname: nil, description: nil, institution_id: nil, name: nil, s1g: nil, s1m: nil, s2g: nil, s2m: nil, s3g: nil, s3m: nil, semester: nil, stuid: nil, subject: nil, year: nil}

  def fixture(:mark_sheet_temp) do
    {:ok, mark_sheet_temp} = Affairs.create_mark_sheet_temp(@create_attrs)
    mark_sheet_temp
  end

  describe "index" do
    test "lists all mark_sheet_temp", %{conn: conn} do
      conn = get conn, mark_sheet_temp_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Mark sheet temp"
    end
  end

  describe "new mark_sheet_temp" do
    test "renders form", %{conn: conn} do
      conn = get conn, mark_sheet_temp_path(conn, :new)
      assert html_response(conn, 200) =~ "New Mark sheet temp"
    end
  end

  describe "create mark_sheet_temp" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, mark_sheet_temp_path(conn, :create), mark_sheet_temp: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == mark_sheet_temp_path(conn, :show, id)

      conn = get conn, mark_sheet_temp_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Mark sheet temp"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, mark_sheet_temp_path(conn, :create), mark_sheet_temp: @invalid_attrs
      assert html_response(conn, 200) =~ "New Mark sheet temp"
    end
  end

  describe "edit mark_sheet_temp" do
    setup [:create_mark_sheet_temp]

    test "renders form for editing chosen mark_sheet_temp", %{conn: conn, mark_sheet_temp: mark_sheet_temp} do
      conn = get conn, mark_sheet_temp_path(conn, :edit, mark_sheet_temp)
      assert html_response(conn, 200) =~ "Edit Mark sheet temp"
    end
  end

  describe "update mark_sheet_temp" do
    setup [:create_mark_sheet_temp]

    test "redirects when data is valid", %{conn: conn, mark_sheet_temp: mark_sheet_temp} do
      conn = put conn, mark_sheet_temp_path(conn, :update, mark_sheet_temp), mark_sheet_temp: @update_attrs
      assert redirected_to(conn) == mark_sheet_temp_path(conn, :show, mark_sheet_temp)

      conn = get conn, mark_sheet_temp_path(conn, :show, mark_sheet_temp)
      assert html_response(conn, 200) =~ "some updated cdesc"
    end

    test "renders errors when data is invalid", %{conn: conn, mark_sheet_temp: mark_sheet_temp} do
      conn = put conn, mark_sheet_temp_path(conn, :update, mark_sheet_temp), mark_sheet_temp: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Mark sheet temp"
    end
  end

  describe "delete mark_sheet_temp" do
    setup [:create_mark_sheet_temp]

    test "deletes chosen mark_sheet_temp", %{conn: conn, mark_sheet_temp: mark_sheet_temp} do
      conn = delete conn, mark_sheet_temp_path(conn, :delete, mark_sheet_temp)
      assert redirected_to(conn) == mark_sheet_temp_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, mark_sheet_temp_path(conn, :show, mark_sheet_temp)
      end
    end
  end

  defp create_mark_sheet_temp(_) do
    mark_sheet_temp = fixture(:mark_sheet_temp)
    {:ok, mark_sheet_temp: mark_sheet_temp}
  end
end
