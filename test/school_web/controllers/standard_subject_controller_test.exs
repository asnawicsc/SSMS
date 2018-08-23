defmodule SchoolWeb.StandardSubjectControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{semester_id: 42, standard_id: 42, subject_id: 42, year: "some year"}
  @update_attrs %{semester_id: 43, standard_id: 43, subject_id: 43, year: "some updated year"}
  @invalid_attrs %{semester_id: nil, standard_id: nil, subject_id: nil, year: nil}

  def fixture(:standard_subject) do
    {:ok, standard_subject} = Affairs.create_standard_subject(@create_attrs)
    standard_subject
  end

  describe "index" do
    test "lists all standard_subject", %{conn: conn} do
      conn = get conn, standard_subject_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Standard subject"
    end
  end

  describe "new standard_subject" do
    test "renders form", %{conn: conn} do
      conn = get conn, standard_subject_path(conn, :new)
      assert html_response(conn, 200) =~ "New Standard subject"
    end
  end

  describe "create standard_subject" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, standard_subject_path(conn, :create), standard_subject: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == standard_subject_path(conn, :show, id)

      conn = get conn, standard_subject_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Standard subject"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, standard_subject_path(conn, :create), standard_subject: @invalid_attrs
      assert html_response(conn, 200) =~ "New Standard subject"
    end
  end

  describe "edit standard_subject" do
    setup [:create_standard_subject]

    test "renders form for editing chosen standard_subject", %{conn: conn, standard_subject: standard_subject} do
      conn = get conn, standard_subject_path(conn, :edit, standard_subject)
      assert html_response(conn, 200) =~ "Edit Standard subject"
    end
  end

  describe "update standard_subject" do
    setup [:create_standard_subject]

    test "redirects when data is valid", %{conn: conn, standard_subject: standard_subject} do
      conn = put conn, standard_subject_path(conn, :update, standard_subject), standard_subject: @update_attrs
      assert redirected_to(conn) == standard_subject_path(conn, :show, standard_subject)

      conn = get conn, standard_subject_path(conn, :show, standard_subject)
      assert html_response(conn, 200) =~ "some updated year"
    end

    test "renders errors when data is invalid", %{conn: conn, standard_subject: standard_subject} do
      conn = put conn, standard_subject_path(conn, :update, standard_subject), standard_subject: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Standard subject"
    end
  end

  describe "delete standard_subject" do
    setup [:create_standard_subject]

    test "deletes chosen standard_subject", %{conn: conn, standard_subject: standard_subject} do
      conn = delete conn, standard_subject_path(conn, :delete, standard_subject)
      assert redirected_to(conn) == standard_subject_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, standard_subject_path(conn, :show, standard_subject)
      end
    end
  end

  defp create_standard_subject(_) do
    standard_subject = fixture(:standard_subject)
    {:ok, standard_subject: standard_subject}
  end
end
