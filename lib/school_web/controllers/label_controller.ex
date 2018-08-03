defmodule SchoolWeb.LabelController do
  use SchoolWeb, :controller

  alias School.Settings
  alias School.Settings.Label
  require IEx

  def index(conn, _params) do
    # labels = Settings.list_labels()

    q = from(l in Label)
    labels = Repo.all(q)

    labels_path = Application.app_dir(:school, "priv/static/fonts")

    unless File.exists?(labels_path <> "/labels-en.json") do
      File.write!(labels_path <> "/labels-en.json", "")
    end

    unless File.exists?(labels_path <> "/labels-cn.json") do
      File.write!(labels_path <> "/labels-cn.json", "")
    end

    unless File.exists?(labels_path <> "/labels-bm.json") do
      File.write!(labels_path <> "/labels-bm.json", "")
    end

    json = labels |> Enum.map(fn x -> {x.name, x.en} end) |> Enum.into(%{}) |> Poison.encode!()
    File.write!(labels_path <> "/labels-en.json", json)
    json = labels |> Enum.map(fn x -> {x.name, x.cn} end) |> Enum.into(%{}) |> Poison.encode!()
    File.write!(labels_path <> "/labels-cn.json", json)
    json = labels |> Enum.map(fn x -> {x.name, x.bm} end) |> Enum.into(%{}) |> Poison.encode!()
    File.write!(labels_path <> "/labels-bm.json", json)

    render(conn, "index.html", labels: labels)
  end

  def new(conn, _params) do
    changeset = Settings.change_label(%Label{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"label" => label_params}) do
    case Settings.create_label(label_params) do
      {:ok, label} ->
        conn
        |> put_flash(:info, "Label created successfully.")
        |> redirect(to: label_path(conn, :show, label))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    label = Settings.get_label!(id)
    render(conn, "show.html", label: label)
  end

  def edit(conn, %{"id" => id}) do
    label = Settings.get_label!(id)
    changeset = Settings.change_label(label)
    render(conn, "edit.html", label: label, changeset: changeset)
  end

  def update(conn, %{"id" => id, "label" => label_params}) do
    label = Settings.get_label!(id)

    case Settings.update_label(label, label_params) do
      {:ok, label} ->
        conn
        |> put_flash(:info, "Label updated successfully.")
        |> redirect(to: label_path(conn, :show, label))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", label: label, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    label = Settings.get_label!(id)
    {:ok, _label} = Settings.delete_label(label)

    conn
    |> put_flash(:info, "Label deleted successfully.")
    |> redirect(to: label_path(conn, :index))
  end
end
