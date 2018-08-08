defmodule SchoolWeb.ParentControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{addr1: "some addr1", addr2: "some addr2", addr3: "some addr3", cname: "some cname", country: "some country", district: "some district", epaddr1: "some epaddr1", epaddr2: "some epaddr2", epaddr3: "some epaddr3", epdistrict: "some epdistrict", epname: "some epname", epposcod: "some epposcod", epstate: "some epstate", hphone: "some hphone", htel: "some htel", icno: "some icno", income: "some income", inctaxno: "some inctaxno", nacert: "some nacert", name: "some name", nation: "some nation", occup: "some occup", oldic: "some oldic", otel: "some otel", poscod: "some poscod", pstatus: "some pstatus", race: "some race", refno: "some refno", relation: "some relation", religion: "some religion", state: "some state", tanggn: "some tanggn"}
  @update_attrs %{addr1: "some updated addr1", addr2: "some updated addr2", addr3: "some updated addr3", cname: "some updated cname", country: "some updated country", district: "some updated district", epaddr1: "some updated epaddr1", epaddr2: "some updated epaddr2", epaddr3: "some updated epaddr3", epdistrict: "some updated epdistrict", epname: "some updated epname", epposcod: "some updated epposcod", epstate: "some updated epstate", hphone: "some updated hphone", htel: "some updated htel", icno: "some updated icno", income: "some updated income", inctaxno: "some updated inctaxno", nacert: "some updated nacert", name: "some updated name", nation: "some updated nation", occup: "some updated occup", oldic: "some updated oldic", otel: "some updated otel", poscod: "some updated poscod", pstatus: "some updated pstatus", race: "some updated race", refno: "some updated refno", relation: "some updated relation", religion: "some updated religion", state: "some updated state", tanggn: "some updated tanggn"}
  @invalid_attrs %{addr1: nil, addr2: nil, addr3: nil, cname: nil, country: nil, district: nil, epaddr1: nil, epaddr2: nil, epaddr3: nil, epdistrict: nil, epname: nil, epposcod: nil, epstate: nil, hphone: nil, htel: nil, icno: nil, income: nil, inctaxno: nil, nacert: nil, name: nil, nation: nil, occup: nil, oldic: nil, otel: nil, poscod: nil, pstatus: nil, race: nil, refno: nil, relation: nil, religion: nil, state: nil, tanggn: nil}

  def fixture(:parent) do
    {:ok, parent} = Affairs.create_parent(@create_attrs)
    parent
  end

  describe "index" do
    test "lists all parent", %{conn: conn} do
      conn = get conn, parent_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Parent"
    end
  end

  describe "new parent" do
    test "renders form", %{conn: conn} do
      conn = get conn, parent_path(conn, :new)
      assert html_response(conn, 200) =~ "New Parent"
    end
  end

  describe "create parent" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, parent_path(conn, :create), parent: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == parent_path(conn, :show, id)

      conn = get conn, parent_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Parent"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, parent_path(conn, :create), parent: @invalid_attrs
      assert html_response(conn, 200) =~ "New Parent"
    end
  end

  describe "edit parent" do
    setup [:create_parent]

    test "renders form for editing chosen parent", %{conn: conn, parent: parent} do
      conn = get conn, parent_path(conn, :edit, parent)
      assert html_response(conn, 200) =~ "Edit Parent"
    end
  end

  describe "update parent" do
    setup [:create_parent]

    test "redirects when data is valid", %{conn: conn, parent: parent} do
      conn = put conn, parent_path(conn, :update, parent), parent: @update_attrs
      assert redirected_to(conn) == parent_path(conn, :show, parent)

      conn = get conn, parent_path(conn, :show, parent)
      assert html_response(conn, 200) =~ "some updated addr1"
    end

    test "renders errors when data is invalid", %{conn: conn, parent: parent} do
      conn = put conn, parent_path(conn, :update, parent), parent: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Parent"
    end
  end

  describe "delete parent" do
    setup [:create_parent]

    test "deletes chosen parent", %{conn: conn, parent: parent} do
      conn = delete conn, parent_path(conn, :delete, parent)
      assert redirected_to(conn) == parent_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, parent_path(conn, :show, parent)
      end
    end
  end

  defp create_parent(_) do
    parent = fixture(:parent)
    {:ok, parent: parent}
  end
end
