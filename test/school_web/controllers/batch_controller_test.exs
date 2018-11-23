defmodule SchoolWeb.BatchControllerTest do
  use SchoolWeb.ConnCase

  alias School.Settings

  @create_attrs %{result: "some result", upload_by: 42}
  @update_attrs %{result: "some updated result", upload_by: 43}
  @invalid_attrs %{result: nil, upload_by: nil}

  def fixture(:batch) do
    {:ok, batch} = Settings.create_batch(@create_attrs)
    batch
  end

  describe "index" do
    test "lists all batches", %{conn: conn} do
      conn = get conn, batch_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Batches"
    end
  end

  describe "new batch" do
    test "renders form", %{conn: conn} do
      conn = get conn, batch_path(conn, :new)
      assert html_response(conn, 200) =~ "New Batch"
    end
  end

  describe "create batch" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, batch_path(conn, :create), batch: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == batch_path(conn, :show, id)

      conn = get conn, batch_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Batch"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, batch_path(conn, :create), batch: @invalid_attrs
      assert html_response(conn, 200) =~ "New Batch"
    end
  end

  describe "edit batch" do
    setup [:create_batch]

    test "renders form for editing chosen batch", %{conn: conn, batch: batch} do
      conn = get conn, batch_path(conn, :edit, batch)
      assert html_response(conn, 200) =~ "Edit Batch"
    end
  end

  describe "update batch" do
    setup [:create_batch]

    test "redirects when data is valid", %{conn: conn, batch: batch} do
      conn = put conn, batch_path(conn, :update, batch), batch: @update_attrs
      assert redirected_to(conn) == batch_path(conn, :show, batch)

      conn = get conn, batch_path(conn, :show, batch)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, batch: batch} do
      conn = put conn, batch_path(conn, :update, batch), batch: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Batch"
    end
  end

  describe "delete batch" do
    setup [:create_batch]

    test "deletes chosen batch", %{conn: conn, batch: batch} do
      conn = delete conn, batch_path(conn, :delete, batch)
      assert redirected_to(conn) == batch_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, batch_path(conn, :show, batch)
      end
    end
  end

  defp create_batch(_) do
    batch = fixture(:batch)
    {:ok, batch: batch}
  end
end
