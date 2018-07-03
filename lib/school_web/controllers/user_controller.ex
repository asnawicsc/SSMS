defmodule SchoolWeb.UserController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.User
  require IEx

  def create_user(conn, params) do

    crypted_password = Comeonin.Bcrypt.hashpwsalt(params["password"])
    params = Map.put(params, "password", crypted_password)

    case Settings.create_user(params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end

  end

  def authenticate(conn, %{"email" => email, "password" => password}) do
    # user = Repo.get_by(User, email: email)

    # if user != nil do
   

    #   if Comeonin.Bcrypt.checkpw(password, p2) do
        conn
        |> put_session(:user_id, 1)
        |> redirect(to: page_path(conn, :index))
    #   else
    #     conn
    #     |> put_flash(:error, "Wrong password!")
    #     |> redirect(to: user_path(conn, :login))
    #   end
    # else
    #   conn
    #   |> put_flash(:error, "User not found")
    #   |> redirect(to: user_path(conn, :login))
    # end
  end

  def login(conn, params) do

     render(conn, "login.html")
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logout successfully")
    |> redirect(to: user_path(conn, :login))
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

  def show(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    changeset = Settings.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Settings.get_user!(id)

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
