defmodule SchoolWeb.Student_coco_achievementController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Student_coco_achievement
  require IEx

  def gen_student_coco_achievement(conn, params) do
    date_from = params["date_from"]
    date_to = params["date_to"]
    class_id = params["class_id"]
    level_id = params["level_id"]
    sort_id = params["sort_id"]
    peringkat = params["peringkat"] |> String.split(",")

    selection =
      cond do
        level_id != "ALL LEVEL" and class_id != "ALL CLASS" ->
          Repo.all(
            from(
              sa in Affairs.Student_coco_achievement,
              left_join: c in Affairs.StudentClass,
              on: c.sudent_id == sa.student_id,
              left_join: t in Affairs.Class,
              on: t.id == c.class_id,
              left_join: s in Affairs.Student,
              on: s.id == sa.student_id,
              where:
                sa.peringkat in ^peringkat and t.level_id == ^level_id and c.class_id == ^class_id and
                  sa.date >= ^date_from and sa.date <= ^date_to,
              select: %{
                desc: sa.competition_name,
                student_name: s.name,
                chinese_name: s.chinese_name,
                date: sa.date,
                peringkat: sa.peringkat,
                class_name: t.name
              },
              order_by: [asc: sa.date]
            )
          )

        level_id != "ALL LEVEL" and class_id == "ALL CLASS" ->
          Repo.all(
            from(
              sa in Affairs.Student_coco_achievement,
              left_join: c in Affairs.StudentClass,
              on: c.sudent_id == sa.student_id,
              left_join: t in Affairs.Class,
              on: t.id == c.class_id,
              left_join: s in Affairs.Student,
              on: s.id == sa.student_id,
              where:
                sa.peringkat in ^peringkat and t.level_id == ^level_id and sa.date >= ^date_from and
                  sa.date <= ^date_to,
              select: %{
                desc: sa.competition_name,
                student_name: s.name,
                chinese_name: s.chinese_name,
                date: sa.date,
                peringkat: sa.peringkat,
                class_name: t.name
              },
              order_by: [asc: sa.date]
            )
          )

        level_id == "ALL LEVEL" ->
          Repo.all(
            from(
              sa in Affairs.Student_coco_achievement,
              left_join: c in Affairs.StudentClass,
              on: c.sudent_id == sa.student_id,
              left_join: t in Affairs.Class,
              on: t.id == c.class_id,
              left_join: s in Affairs.Student,
              on: s.id == sa.student_id,
              where: sa.peringkat in ^peringkat and sa.date >= ^date_from and sa.date <= ^date_to,
              select: %{
                desc: sa.competition_name,
                student_name: s.name,
                chinese_name: s.chinese_name,
                date: sa.date,
                peringkat: sa.peringkat,
                class_name: t.name
              },
              order_by: [asc: sa.date]
            )
          )
      end

    sekolah =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Sekolah" end)

    zon =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Zon" end)

    negeri =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Negeri" end)

    kebangsaan =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Kebangsaan" end)

    antarabangsa =
      selection
      |> Enum.filter(fn x -> x.peringkat == "Antarabangsa" end)

    html =
      if selection != [] do
        Phoenix.View.render_to_string(
          SchoolWeb.Student_coco_achievementView,
          "student_achievement_report_pdf.html",
          selection: selection,
          sekolah: sekolah,
          zon: zon,
          negeri: negeri,
          kebangsaan: kebangsaan,
          antarabangsa: antarabangsa,
          date_to: date_to,
          date_from: date_from,
          class_id: class_id,
          level_id: level_id,
          sort_id: sort_id,
          peringkat: peringkat
        )
      end

    pdf_params = %{"html" => html}

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_header("Content-Type", "application/pdf")
    |> resp(200, pdf_binary)
  end

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
