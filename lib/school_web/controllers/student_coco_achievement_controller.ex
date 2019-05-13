defmodule SchoolWeb.Student_coco_achievementController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Student_coco_achievement
  require IEx

  def index(conn, _params) do
    student_coco_achievements = Affairs.list_student_coco_achievements()
    render(conn, "index.html", student_coco_achievements: student_coco_achievements)
  end

  def new(conn, _params) do
    changeset = Affairs.change_student_coco_achievement(%Student_coco_achievement{})
    render(conn, "new.html", changeset: changeset)
  end

  def add_achievement(conn, _params) do
    inst_id = Affairs.get_inst_id(conn)
    cocos = Affairs.list_cocurriculum(Affairs.get_inst_id(conn))
    semesters = Affairs.list_semesters(inst_id)

    rank =
      Repo.all(
        from(a in School.Affairs.Coco_Rank, select: %{sub_category: a.sub_category, rank: a.rank})
      )

    class =
      Repo.all(
        from(
          s in School.Affairs.Class,
          where: s.institution_id == ^conn.private.plug_session["institution_id"],
          select: %{institution_id: s.institution_id, id: s.id, name: s.name},
          order_by: [s.name]
        )
      )

    changeset = Affairs.change_student_coco_achievement(%Student_coco_achievement{})

    render(
      conn,
      "add_achievement.html",
      changeset: changeset,
      cocos: cocos,
      semesters: semesters,
      class: class,
      rank: rank
    )
  end

  def gen_report(conn, _params) do
    render(conn, "generate_report.html")
  end

  def create(conn, %{"student_coco_achievement" => student_coco_achievement_params}) do
    case Affairs.create_student_coco_achievement(student_coco_achievement_params) do
      {:ok, student_coco_achievement} ->
        conn
        |> put_flash(:info, "Student coco achievement created successfully.")
        |> redirect(to: student_coco_achievement_path(conn, :show, student_coco_achievement))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    student_coco_achievement = Affairs.get_student_coco_achievement!(id)
    render(conn, "show.html", student_coco_achievement: student_coco_achievement)
  end

  def edit(conn, %{"id" => id}) do
    student_coco_achievement = Affairs.get_student_coco_achievement!(id)
    changeset = Affairs.change_student_coco_achievement(student_coco_achievement)

    render(
      conn,
      "edit.html",
      student_coco_achievement: student_coco_achievement,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "student_coco_achievement" => student_coco_achievement_params}) do
    student_coco_achievement = Affairs.get_student_coco_achievement!(id)

    case Affairs.update_student_coco_achievement(
           student_coco_achievement,
           student_coco_achievement_params
         ) do
      {:ok, student_coco_achievement} ->
        conn
        |> put_flash(:info, "Student coco achievement updated successfully.")
        |> redirect(to: student_coco_achievement_path(conn, :show, student_coco_achievement))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          student_coco_achievement: student_coco_achievement,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    student_coco_achievement = Affairs.get_student_coco_achievement!(id)

    {:ok, _student_coco_achievement} =
      Affairs.delete_student_coco_achievement(student_coco_achievement)

    conn
    |> put_flash(:info, "Student coco achievement deleted successfully.")
    |> redirect(to: student_coco_achievement_path(conn, :index))
  end
end
