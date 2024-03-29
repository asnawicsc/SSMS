defmodule SchoolWeb.InstitutionController do
  use SchoolWeb, :controller
  require IEx

  alias School.Settings
  alias School.Settings.{Institution, User, Parameter}
  require IEx
  import Mogrify

  def select(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    user = Settings.current_user(conn)
    User.changeset(user, %{institution_id: id}) |> Repo.update!()

    conn
    |> put_session(:institution_id, id)
    |> put_flash(:info, "#{institution.name} selected!")
    |> redirect(to: institution_path(conn, :index))
  end

  def pre_upload(conn, params) do
    # IEx.pry()

    # write the upload to a directory

    # execute the porcelain commands

    # get the output and process it...

    conn
    |> put_flash(:info, "Processing!")
    |> redirect(to: institution_path(conn, :index))
  end

  def upload(conn, params) do
    render(conn, "upload.html", [])
  end

  def list_institutions(conn, _params) do
    institution = Settings.list_institutions()

    render(conn, "list_institutions.html", institution: institution)
  end

  def index(conn, _params) do
    if User.institution_id(conn) != nil do
      ins = User.institution_id(conn)

      institution = Settings.get_institution!(ins)

      param = Repo.get_by(Parameter, institution_id: ins)

      render(conn, "show.html", institution: institution, param: param)
    else
      institutions = Settings.list_institutions()
      render(conn, "index.html", institutions: institutions)
    end
  end

  def new(conn, _params) do
    changeset = Settings.change_institution(%Institution{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"institution" => institution_params}) do
    image_params = institution_params["image1"]
    result = upload_image(image_params)

    institution_params = Map.put(institution_params, "logo_bin", result.bin)
    institution_params = Map.put(institution_params, "logo_filename", result.filename)

    case Settings.create_institution(institution_params) do
      {:ok, institution} ->
        conn
        |> put_flash(:info, "Institution created successfully.")
        |> redirect(to: institution_path(conn, :show, institution))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def upload_image(param) do
    {:ok, seconds} = Timex.format(Timex.now(), "%s", :strftime)

    path = File.cwd!() <> "/media"
    image_path = Application.app_dir(:school, "priv/static/images")

    if File.exists?(path) == false do
      File.mkdir(File.cwd!() <> "/media")
    end

    fl = param.filename |> String.replace(" ", "_")
    absolute_path = path <> "/#{seconds <> fl}"
    absolute_path_bin = path <> "/bin_" <> "#{seconds <> fl}"
    File.cp(param.path, absolute_path)
    File.rm(image_path <> "/uploads")
    File.ln_s(path, image_path <> "/uploads")

    resized = Mogrify.open(absolute_path) |> resize("200x200") |> save(path: absolute_path_bin)
    {:ok, bin} = File.read(resized.path)

    # File.rm(resized.path)

    %{filename: seconds <> fl, bin: Base.encode64(bin)}
  end

  def show(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    param = Repo.get_by(Parameter, institution_id: id)

    render(conn, "show.html", institution: institution, param: param)
  end

  def edit(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    changeset = Settings.change_institution(institution)
    render(conn, "edit.html", institution: institution, changeset: changeset)
  end

  def update(conn, %{"id" => id, "institution" => institution_params}) do
    institution = Settings.get_institution!(id)
    image_params = institution_params["image1"]

    if image_params != nil do
      result = upload_image(image_params)
      institution_params = Map.put(institution_params, "logo_bin", result.bin)
      institution_params = Map.put(institution_params, "logo_filename", result.filename)
    end

    case Settings.update_institution(institution, institution_params) do
      {:ok, institution} ->
        conn
        |> put_flash(:info, "Institution updated successfully.")
        |> redirect(to: institution_path(conn, :show, institution))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", institution: institution, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    institution = Settings.get_institution!(id)
    {:ok, _institution} = Settings.delete_institution(institution)

    conn
    |> put_flash(:info, "Institution deleted successfully.")
    |> redirect(to: institution_path(conn, :index))
  end
end
