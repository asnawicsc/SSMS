defmodule SchoolWeb.CommentControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{c_chinese: "some c_chinese", c_malay: "some c_malay", code: "some code"}
  @update_attrs %{c_chinese: "some updated c_chinese", c_malay: "some updated c_malay", code: "some updated code"}
  @invalid_attrs %{c_chinese: nil, c_malay: nil, code: nil}

  def fixture(:comment) do
    {:ok, comment} = Affairs.create_comment(@create_attrs)
    comment
  end

  describe "index" do
    test "lists all comment", %{conn: conn} do
      conn = get conn, comment_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Comment"
    end
  end

  describe "new comment" do
    test "renders form", %{conn: conn} do
      conn = get conn, comment_path(conn, :new)
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "create comment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, comment_path(conn, :create), comment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == comment_path(conn, :show, id)

      conn = get conn, comment_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Comment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, comment_path(conn, :create), comment: @invalid_attrs
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "edit comment" do
    setup [:create_comment]

    test "renders form for editing chosen comment", %{conn: conn, comment: comment} do
      conn = get conn, comment_path(conn, :edit, comment)
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "update comment" do
    setup [:create_comment]

    test "redirects when data is valid", %{conn: conn, comment: comment} do
      conn = put conn, comment_path(conn, :update, comment), comment: @update_attrs
      assert redirected_to(conn) == comment_path(conn, :show, comment)

      conn = get conn, comment_path(conn, :show, comment)
      assert html_response(conn, 200) =~ "some updated c_chinese"
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment} do
      conn = put conn, comment_path(conn, :update, comment), comment: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "delete comment" do
    setup [:create_comment]

    test "deletes chosen comment", %{conn: conn, comment: comment} do
      conn = delete conn, comment_path(conn, :delete, comment)
      assert redirected_to(conn) == comment_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, comment_path(conn, :show, comment)
      end
    end
  end

  defp create_comment(_) do
    comment = fixture(:comment)
    {:ok, comment: comment}
  end
end
