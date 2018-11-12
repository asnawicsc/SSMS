defmodule SchoolWeb.ContactUsController do
  use SchoolWeb, :controller

  alias School.Setting
  alias School.Setting.ContactUs
  require IEx

  def index(conn, _params) do
    contact_us = Setting.list_contact_us()
    render(conn, "index.html", contact_us: contact_us)
  end

  def new(conn, _params) do
    changeset = Setting.change_contact_us(%ContactUs{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"contact_us" => contact_us_params}) do
    case Setting.create_contact_us(contact_us_params) do
      {:ok, contact_us} ->
        conn
        |> put_flash(:info, "Contact us created successfully.")
        |> redirect(to: contact_us_path(conn, :show, contact_us))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def contact_us_feedback(conn, params) do
    params = %{email: params["email"], name: params["name"], message: params["message"]}

    case Setting.create_contact_us(params) do
      {:ok, contact_us} ->
        conn
        |> put_flash(:info, "Thank you for getting in touch!")
        |> redirect(to: page_path(conn, :index_splash))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    contact_us = Setting.get_contact_us!(id)
    render(conn, "show.html", contact_us: contact_us)
  end

  def edit(conn, %{"id" => id}) do
    contact_us = Setting.get_contact_us!(id)
    changeset = Setting.change_contact_us(contact_us)
    render(conn, "edit.html", contact_us: contact_us, changeset: changeset)
  end

  def update(conn, %{"id" => id, "contact_us" => contact_us_params}) do
    contact_us = Setting.get_contact_us!(id)

    case Setting.update_contact_us(contact_us, contact_us_params) do
      {:ok, contact_us} ->
        conn
        |> put_flash(:info, "Contact us updated successfully.")
        |> redirect(to: contact_us_path(conn, :show, contact_us))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", contact_us: contact_us, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    contact_us = Setting.get_contact_us!(id)
    {:ok, _contact_us} = Setting.delete_contact_us(contact_us)

    conn
    |> put_flash(:info, "Contact us deleted successfully.")
    |> redirect(to: contact_us_path(conn, :index))
  end
end
