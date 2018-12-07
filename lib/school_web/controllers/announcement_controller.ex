defmodule SchoolWeb.AnnouncementController do
  use SchoolWeb, :controller

  alias School.Affairs
  alias School.Affairs.Announcement
  require IEx

  def broadcast(conn, %{"id" => id}) do
    announcement = Affairs.get_announcement!(id)

    parents =
      Repo.all(
        from(
          p in Parent,
          where: p.institution_id == ^Affairs.get_inst_id(conn) and not is_nil(p.fb_user_id)
        )
      )

    for parent <- parents do
      list_map = [%{announcement: announcement.message}]
      SchoolWeb.ApiController.school_broadcast("inform_parents", list_map, parent.psid)
      :timer.sleep(200)
    end

    conn
    |> put_flash(:info, "Announcement broadcast successfully.")
    |> redirect(to: announcement_path(conn, :index))
  end

  def index(conn, _params) do
    announcements = Affairs.list_announcements(Affairs.get_inst_id(conn))
    render(conn, "index.html", announcements: announcements)
  end

  def new(conn, _params) do
    changeset = Affairs.change_announcement(%Announcement{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"announcement" => announcement_params}) do
    announcement_params =
      Map.put(announcement_params, "institution_id", Affairs.get_inst_id(conn))

    case Affairs.create_announcement(announcement_params) do
      {:ok, announcement} ->
        conn
        |> put_flash(:info, "Announcement created successfully.")
        |> redirect(to: announcement_path(conn, :show, announcement))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    announcement = Affairs.get_announcement!(id)
    render(conn, "show.html", announcement: announcement)
  end

  def edit(conn, %{"id" => id}) do
    announcement = Affairs.get_announcement!(id)
    changeset = Affairs.change_announcement(announcement)
    render(conn, "edit.html", announcement: announcement, changeset: changeset)
  end

  def update(conn, %{"id" => id, "announcement" => announcement_params}) do
    announcement = Affairs.get_announcement!(id)

    case Affairs.update_announcement(announcement, announcement_params) do
      {:ok, announcement} ->
        conn
        |> put_flash(:info, "Announcement updated successfully.")
        |> redirect(to: announcement_path(conn, :show, announcement))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", announcement: announcement, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    announcement = Affairs.get_announcement!(id)
    {:ok, _announcement} = Affairs.delete_announcement(announcement)

    conn
    |> put_flash(:info, "Announcement deleted successfully.")
    |> redirect(to: announcement_path(conn, :index))
  end
end
