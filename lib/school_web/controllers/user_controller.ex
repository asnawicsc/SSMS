defmodule SchoolWeb.UserController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.User
  require IEx

  def create_user(conn, params) do
    crypted_password = Comeonin.Bcrypt.hashpwsalt(params["password"])
    params = Map.put(params, "crypted_password", crypted_password)
    params = Map.delete(params, "password")

    case Settings.create_user(params) do
      {:ok, user} ->
        # |> put_session(:user_id, user.id)
        # |> put_flash(:info, "Please select a school.")
        conn
        |> redirect(to: user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def change_semester(conn, params) do
    user = Repo.get_by(User, id: conn.private.plug_session["user_id"])

    access = Repo.get_by(Settings.UserAccess, user_id: user.id)

    current_sem =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where:
            s.id == ^conn.private.plug_session["semester_id"] and
              s.institution_id == ^access.institution_id
        )
      )
      |> hd

    all =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where: s.institution_id == ^access.institution_id
        )
      )

    render(conn, "change_semester.html", current_sem: current_sem, all: all)
  end

  def assign_lib_access(conn, params) do
    users =
      Repo.all(
        from(s in User,
          left_join: g in Settings.UserAccess,
          on: s.id == g.user_id,
          where: g.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )

    render(conn, "library_assign.html", users: users)
  end

  def get_change_semester(conn, params) do
    semester =
      Repo.all(
        from(
          s in School.Affairs.Semester,
          where:
            s.id == ^params["change_semester"] and
              s.institution_id == ^conn.private.plug_session["institution_id"]
        )
      )
      |> hd

    user = Repo.get_by(User, id: conn.private.plug_session["user_id"])

    conn
    |> put_session(:user_id, user.id)
    |> put_session(:semester_id, semester.id)
    |> put_session(:institution_id, conn.private.plug_session["institution_id"])
    |> put_session(:style, user.styles)
    |> redirect(to: page_path(conn, :dashboard))
  end

  def authenticate(conn, %{"email" => email, "password" => password}) do
    user = Repo.get_by(User, email: email)

    if user != nil do
      if Comeonin.Bcrypt.checkpw(password, user.crypted_password) do
        if user.role == "Admin" do
          institution_id = Repo.get_by(Settings.Institution, name: "test")

          current_sem =
            Repo.all(
              from(
                s in School.Affairs.Semester,
                where:
                  s.end_date > ^Timex.today() and s.start_date <= ^Timex.today() and
                    s.institution_id == ^institution_id.id
              )
            )

          current_sem =
            if current_sem != [] do
              hd(current_sem)
            else
              %{id: 0, start_date: "Not set", end_date: "Not set"}
            end

          conn
          |> put_session(:user_id, user.id)
          |> put_session(:semester_id, current_sem.id)
          |> put_session(:institution_id, institution_id.id)
          |> put_session(:style, user.styles)
          |> redirect(to: page_path(conn, :admin_dashboard))
        end

        access = Repo.get_by(Settings.UserAccess, user_id: user.id)

        current_sem =
          Repo.all(
            from(
              s in School.Affairs.Semester,
              where:
                s.end_date > ^Timex.today() and s.start_date < ^Timex.today() and
                  s.institution_id == ^access.institution_id
            )
          )

        user = Repo.get_by(User, id: user.id)

        current_sem =
          if current_sem != [] do
            hd(current_sem)
          else
            %{id: 0, start_date: "Not set", end_date: "Not set"}
          end

        if access == nil do
          conn
          |> put_flash(:error, "Please Contact Admin for Access!")
          |> redirect(to: page_path(conn, :index_splash))
        else
          if user.role == "Support" do
            conn
            |> put_session(:user_id, user.id)
            |> put_session(:semester_id, current_sem.id)
            |> put_session(:institution_id, access.institution_id)
            |> put_session(:style, user.styles)
            |> redirect(to: page_path(conn, :support_dashboard))
          else
            if user.role == "Clerk" do
              conn
              |> put_session(:user_id, user.id)
              |> put_session(:semester_id, current_sem.id)
              |> put_session(:institution_id, access.institution_id)
              |> put_session(:style, user.styles)
              |> redirect(to: page_path(conn, :clerk_dashboard))
            else
              conn
              |> put_session(:user_id, user.id)
              |> put_session(:semester_id, current_sem.id)
              |> put_session(:institution_id, access.institution_id)
              |> put_session(:style, user.styles)
              |> redirect(to: page_path(conn, :dashboard))
            end
          end
        end
      else
        conn
        |> put_flash(:error, "Wrong password!")
        |> redirect(to: page_path(conn, :index_splash))
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: page_path(conn, :index_splash))
    end
  end

  def login(conn, params) do
    user = Repo.all(User)

    if user != [] do
      admin = user |> Enum.filter(fn x -> x.role == "Admin" end)

      if admin == [] do
        password = "abc123"
        crypted_password = Comeonin.Bcrypt.hashpwsalt(password)

        user_params = %{
          email: "admin@gmail.com",
          password: password,
          crypted_password: crypted_password,
          role: "Admin"
        }

        case Settings.create_user(user_params) do
          {:ok, user} ->
            Settings.create_institution(%{
              name: "test"
            })

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      end
    else
      password = "abc123"
      crypted_password = Comeonin.Bcrypt.hashpwsalt(password)

      user_params = %{
        email: "admin@gmail.com",
        password: password,
        crypted_password: crypted_password,
        role: "Admin"
      }

      case Settings.create_user(user_params) do
        {:ok, user} ->
          Settings.create_institution(%{
            name: "test"
          })

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end

    render(conn, "login.html")
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> delete_session(:institution_id)
    |> delete_session(:semester_id)
    |> delete_session(:style)
    |> put_flash(:info, "Logout successfully")
    |> redirect(to: page_path(conn, :index_splash))
  end

  def register_new_user(conn, _params) do
    render(conn, "register_new_user.html")
  end

  def create_clerk(conn, _params) do
    users =
      Repo.all(
        from(s in User,
          left_join: g in Settings.UserAccess,
          on: s.id == g.user_id,
          where:
            g.institution_id == ^conn.private.plug_session["institution_id"] and s.role == "Clerk"
        )
      )

    render(conn, "create_clerk.html", users: users)
  end

  def index(conn, _params) do
    users = Settings.list_users()

    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Settings.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Settings.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def user_info(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def show(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    changeset = Settings.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params, "is_librarian" => is_librarian}) do
    user = Settings.get_user!(id)

    crypted_password = Comeonin.Bcrypt.hashpwsalt(user_params["password"])

    user_params = Map.put(user_params, "is_librarian", is_librarian)
    user_params = Map.put(user_params, "crypted_password", crypted_password)

    case Settings.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    {:ok, _user} = Settings.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
