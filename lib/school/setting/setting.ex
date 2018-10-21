defmodule School.Setting do
  @moduledoc """
  The Setting context.
  """

  import Ecto.Query, warn: false
  alias School.Repo

  alias School.Setting.ContactUs

  @doc """
  Returns the list of contact_us.

  ## Examples

      iex> list_contact_us()
      [%ContactUs{}, ...]

  """
  def list_contact_us do
    Repo.all(ContactUs)
  end

  @doc """
  Gets a single contact_us.

  Raises `Ecto.NoResultsError` if the Contact us does not exist.

  ## Examples

      iex> get_contact_us!(123)
      %ContactUs{}

      iex> get_contact_us!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_us!(id), do: Repo.get!(ContactUs, id)

  @doc """
  Creates a contact_us.

  ## Examples

      iex> create_contact_us(%{field: value})
      {:ok, %ContactUs{}}

      iex> create_contact_us(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_us(attrs \\ %{}) do
    %ContactUs{}
    |> ContactUs.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact_us.

  ## Examples

      iex> update_contact_us(contact_us, %{field: new_value})
      {:ok, %ContactUs{}}

      iex> update_contact_us(contact_us, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact_us(%ContactUs{} = contact_us, attrs) do
    contact_us
    |> ContactUs.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ContactUs.

  ## Examples

      iex> delete_contact_us(contact_us)
      {:ok, %ContactUs{}}

      iex> delete_contact_us(contact_us)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact_us(%ContactUs{} = contact_us) do
    Repo.delete(contact_us)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact_us changes.

  ## Examples

      iex> change_contact_us(contact_us)
      %Ecto.Changeset{source: %ContactUs{}}

  """
  def change_contact_us(%ContactUs{} = contact_us) do
    ContactUs.changeset(contact_us, %{})
  end
end
