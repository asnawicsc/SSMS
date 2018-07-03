defmodule SchoolWeb.InstitutionControllerTest do
  use SchoolWeb.ConnCase

  alias School.Settings

  @create_attrs %{country: "some country", email: "some email", email2: "some email2", fax: "some fax", line1: "some line1", line2: "some line2", logo_bin: "some logo_bin", logo_filename: "some logo_filename", name: "some name", phone: "some phone", phone2: "some phone2", postcode: "some postcode", state: "some state", town: "some town"}
  @update_attrs %{country: "some updated country", email: "some updated email", email2: "some updated email2", fax: "some updated fax", line1: "some updated line1", line2: "some updated line2", logo_bin: "some updated logo_bin", logo_filename: "some updated logo_filename", name: "some updated name", phone: "some updated phone", phone2: "some updated phone2", postcode: "some updated postcode", state: "some updated state", town: "some updated town"}
  @invalid_attrs %{country: nil, email: nil, email2: nil, fax: nil, line1: nil, line2: nil, logo_bin: nil, logo_filename: nil, name: nil, phone: nil, phone2: nil, postcode: nil, state: nil, town: nil}

  def fixture(:institution) do
    {:ok, institution} = Settings.create_institution(@create_attrs)
    institution
  end

  describe "index" do
    test "lists all institutions", %{conn: conn} do
      conn = get conn, institution_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Institutions"
    end
  end

  describe "new institution" do
    test "renders form", %{conn: conn} do
      conn = get conn, institution_path(conn, :new)
      assert html_response(conn, 200) =~ "New Institution"
    end
  end

  describe "create institution" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, institution_path(conn, :create), institution: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == institution_path(conn, :show, id)

      conn = get conn, institution_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Institution"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, institution_path(conn, :create), institution: @invalid_attrs
      assert html_response(conn, 200) =~ "New Institution"
    end
  end

  describe "edit institution" do
    setup [:create_institution]

    test "renders form for editing chosen institution", %{conn: conn, institution: institution} do
      conn = get conn, institution_path(conn, :edit, institution)
      assert html_response(conn, 200) =~ "Edit Institution"
    end
  end

  describe "update institution" do
    setup [:create_institution]

    test "redirects when data is valid", %{conn: conn, institution: institution} do
      conn = put conn, institution_path(conn, :update, institution), institution: @update_attrs
      assert redirected_to(conn) == institution_path(conn, :show, institution)

      conn = get conn, institution_path(conn, :show, institution)
      assert html_response(conn, 200) =~ "some updated country"
    end

    test "renders errors when data is invalid", %{conn: conn, institution: institution} do
      conn = put conn, institution_path(conn, :update, institution), institution: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Institution"
    end
  end

  describe "delete institution" do
    setup [:create_institution]

    test "deletes chosen institution", %{conn: conn, institution: institution} do
      conn = delete conn, institution_path(conn, :delete, institution)
      assert redirected_to(conn) == institution_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, institution_path(conn, :show, institution)
      end
    end
  end

  defp create_institution(_) do
    institution = fixture(:institution)
    {:ok, institution: institution}
  end
end
