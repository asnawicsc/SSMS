defmodule SchoolWeb.LabelControllerTest do
  use SchoolWeb.ConnCase

  alias School.Settings

  @create_attrs %{bm: "some bm", cn: "some cn", en: "some en", name: "some name"}
  @update_attrs %{bm: "some updated bm", cn: "some updated cn", en: "some updated en", name: "some updated name"}
  @invalid_attrs %{bm: nil, cn: nil, en: nil, name: nil}

  def fixture(:label) do
    {:ok, label} = Settings.create_label(@create_attrs)
    label
  end

  describe "index" do
    test "lists all labels", %{conn: conn} do
      conn = get conn, label_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Labels"
    end
  end

  describe "new label" do
    test "renders form", %{conn: conn} do
      conn = get conn, label_path(conn, :new)
      assert html_response(conn, 200) =~ "New Label"
    end
  end

  describe "create label" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, label_path(conn, :create), label: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == label_path(conn, :show, id)

      conn = get conn, label_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Label"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, label_path(conn, :create), label: @invalid_attrs
      assert html_response(conn, 200) =~ "New Label"
    end
  end

  describe "edit label" do
    setup [:create_label]

    test "renders form for editing chosen label", %{conn: conn, label: label} do
      conn = get conn, label_path(conn, :edit, label)
      assert html_response(conn, 200) =~ "Edit Label"
    end
  end

  describe "update label" do
    setup [:create_label]

    test "redirects when data is valid", %{conn: conn, label: label} do
      conn = put conn, label_path(conn, :update, label), label: @update_attrs
      assert redirected_to(conn) == label_path(conn, :show, label)

      conn = get conn, label_path(conn, :show, label)
      assert html_response(conn, 200) =~ "some updated bm"
    end

    test "renders errors when data is invalid", %{conn: conn, label: label} do
      conn = put conn, label_path(conn, :update, label), label: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Label"
    end
  end

  describe "delete label" do
    setup [:create_label]

    test "deletes chosen label", %{conn: conn, label: label} do
      conn = delete conn, label_path(conn, :delete, label)
      assert redirected_to(conn) == label_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, label_path(conn, :show, label)
      end
    end
  end

  defp create_label(_) do
    label = fixture(:label)
    {:ok, label: label}
  end
end
