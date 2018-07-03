defmodule SchoolWeb.ParameterControllerTest do
  use SchoolWeb.ConnCase

  alias School.Settings

  @create_attrs %{blood_type: "some blood_type", career: "some career", nationality: "some nationality", oku: "some oku", race: "some race", religion: "some religion", sickness: "some sickness", transport: "some transport"}
  @update_attrs %{blood_type: "some updated blood_type", career: "some updated career", nationality: "some updated nationality", oku: "some updated oku", race: "some updated race", religion: "some updated religion", sickness: "some updated sickness", transport: "some updated transport"}
  @invalid_attrs %{blood_type: nil, career: nil, nationality: nil, oku: nil, race: nil, religion: nil, sickness: nil, transport: nil}

  def fixture(:parameter) do
    {:ok, parameter} = Settings.create_parameter(@create_attrs)
    parameter
  end

  describe "index" do
    test "lists all parameters", %{conn: conn} do
      conn = get conn, parameter_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Parameters"
    end
  end

  describe "new parameter" do
    test "renders form", %{conn: conn} do
      conn = get conn, parameter_path(conn, :new)
      assert html_response(conn, 200) =~ "New Parameter"
    end
  end

  describe "create parameter" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, parameter_path(conn, :create), parameter: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == parameter_path(conn, :show, id)

      conn = get conn, parameter_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Parameter"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, parameter_path(conn, :create), parameter: @invalid_attrs
      assert html_response(conn, 200) =~ "New Parameter"
    end
  end

  describe "edit parameter" do
    setup [:create_parameter]

    test "renders form for editing chosen parameter", %{conn: conn, parameter: parameter} do
      conn = get conn, parameter_path(conn, :edit, parameter)
      assert html_response(conn, 200) =~ "Edit Parameter"
    end
  end

  describe "update parameter" do
    setup [:create_parameter]

    test "redirects when data is valid", %{conn: conn, parameter: parameter} do
      conn = put conn, parameter_path(conn, :update, parameter), parameter: @update_attrs
      assert redirected_to(conn) == parameter_path(conn, :show, parameter)

      conn = get conn, parameter_path(conn, :show, parameter)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, parameter: parameter} do
      conn = put conn, parameter_path(conn, :update, parameter), parameter: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Parameter"
    end
  end

  describe "delete parameter" do
    setup [:create_parameter]

    test "deletes chosen parameter", %{conn: conn, parameter: parameter} do
      conn = delete conn, parameter_path(conn, :delete, parameter)
      assert redirected_to(conn) == parameter_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, parameter_path(conn, :show, parameter)
      end
    end
  end

  defp create_parameter(_) do
    parameter = fixture(:parameter)
    {:ok, parameter: parameter}
  end
end
