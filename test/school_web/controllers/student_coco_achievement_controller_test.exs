defmodule SchoolWeb.Student_coco_achievementControllerTest do
  use SchoolWeb.ConnCase

  alias School.Affairs

  @create_attrs %{category: "some category", competition_name: "some competition_name", date: ~D[2010-04-17], participant_type: "some participant_type", peringkat: "some peringkat", rank: "some rank", student_id: 42, sub_category: "some sub_category"}
  @update_attrs %{category: "some updated category", competition_name: "some updated competition_name", date: ~D[2011-05-18], participant_type: "some updated participant_type", peringkat: "some updated peringkat", rank: "some updated rank", student_id: 43, sub_category: "some updated sub_category"}
  @invalid_attrs %{category: nil, competition_name: nil, date: nil, participant_type: nil, peringkat: nil, rank: nil, student_id: nil, sub_category: nil}

  def fixture(:student_coco_achievement) do
    {:ok, student_coco_achievement} = Affairs.create_student_coco_achievement(@create_attrs)
    student_coco_achievement
  end

  describe "index" do
    test "lists all student_coco_achievements", %{conn: conn} do
      conn = get conn, student_coco_achievement_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Student coco achievements"
    end
  end

  describe "new student_coco_achievement" do
    test "renders form", %{conn: conn} do
      conn = get conn, student_coco_achievement_path(conn, :new)
      assert html_response(conn, 200) =~ "New Student coco achievement"
    end
  end

  describe "create student_coco_achievement" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, student_coco_achievement_path(conn, :create), student_coco_achievement: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == student_coco_achievement_path(conn, :show, id)

      conn = get conn, student_coco_achievement_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Student coco achievement"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, student_coco_achievement_path(conn, :create), student_coco_achievement: @invalid_attrs
      assert html_response(conn, 200) =~ "New Student coco achievement"
    end
  end

  describe "edit student_coco_achievement" do
    setup [:create_student_coco_achievement]

    test "renders form for editing chosen student_coco_achievement", %{conn: conn, student_coco_achievement: student_coco_achievement} do
      conn = get conn, student_coco_achievement_path(conn, :edit, student_coco_achievement)
      assert html_response(conn, 200) =~ "Edit Student coco achievement"
    end
  end

  describe "update student_coco_achievement" do
    setup [:create_student_coco_achievement]

    test "redirects when data is valid", %{conn: conn, student_coco_achievement: student_coco_achievement} do
      conn = put conn, student_coco_achievement_path(conn, :update, student_coco_achievement), student_coco_achievement: @update_attrs
      assert redirected_to(conn) == student_coco_achievement_path(conn, :show, student_coco_achievement)

      conn = get conn, student_coco_achievement_path(conn, :show, student_coco_achievement)
      assert html_response(conn, 200) =~ "some updated category"
    end

    test "renders errors when data is invalid", %{conn: conn, student_coco_achievement: student_coco_achievement} do
      conn = put conn, student_coco_achievement_path(conn, :update, student_coco_achievement), student_coco_achievement: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Student coco achievement"
    end
  end

  describe "delete student_coco_achievement" do
    setup [:create_student_coco_achievement]

    test "deletes chosen student_coco_achievement", %{conn: conn, student_coco_achievement: student_coco_achievement} do
      conn = delete conn, student_coco_achievement_path(conn, :delete, student_coco_achievement)
      assert redirected_to(conn) == student_coco_achievement_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, student_coco_achievement_path(conn, :show, student_coco_achievement)
      end
    end
  end

  defp create_student_coco_achievement(_) do
    student_coco_achievement = fixture(:student_coco_achievement)
    {:ok, student_coco_achievement: student_coco_achievement}
  end
end
