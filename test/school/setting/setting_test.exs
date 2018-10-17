defmodule School.SettingTest do
  use School.DataCase

  alias School.Setting

  describe "contact_us" do
    alias School.Setting.ContactUs

    @valid_attrs %{email: "some email", message: "some message", name: "some name"}
    @update_attrs %{email: "some updated email", message: "some updated message", name: "some updated name"}
    @invalid_attrs %{email: nil, message: nil, name: nil}

    def contact_us_fixture(attrs \\ %{}) do
      {:ok, contact_us} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Setting.create_contact_us()

      contact_us
    end

    test "list_contact_us/0 returns all contact_us" do
      contact_us = contact_us_fixture()
      assert Setting.list_contact_us() == [contact_us]
    end

    test "get_contact_us!/1 returns the contact_us with given id" do
      contact_us = contact_us_fixture()
      assert Setting.get_contact_us!(contact_us.id) == contact_us
    end

    test "create_contact_us/1 with valid data creates a contact_us" do
      assert {:ok, %ContactUs{} = contact_us} = Setting.create_contact_us(@valid_attrs)
      assert contact_us.email == "some email"
      assert contact_us.message == "some message"
      assert contact_us.name == "some name"
    end

    test "create_contact_us/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Setting.create_contact_us(@invalid_attrs)
    end

    test "update_contact_us/2 with valid data updates the contact_us" do
      contact_us = contact_us_fixture()
      assert {:ok, contact_us} = Setting.update_contact_us(contact_us, @update_attrs)
      assert %ContactUs{} = contact_us
      assert contact_us.email == "some updated email"
      assert contact_us.message == "some updated message"
      assert contact_us.name == "some updated name"
    end

    test "update_contact_us/2 with invalid data returns error changeset" do
      contact_us = contact_us_fixture()
      assert {:error, %Ecto.Changeset{}} = Setting.update_contact_us(contact_us, @invalid_attrs)
      assert contact_us == Setting.get_contact_us!(contact_us.id)
    end

    test "delete_contact_us/1 deletes the contact_us" do
      contact_us = contact_us_fixture()
      assert {:ok, %ContactUs{}} = Setting.delete_contact_us(contact_us)
      assert_raise Ecto.NoResultsError, fn -> Setting.get_contact_us!(contact_us.id) end
    end

    test "change_contact_us/1 returns a contact_us changeset" do
      contact_us = contact_us_fixture()
      assert %Ecto.Changeset{} = Setting.change_contact_us(contact_us)
    end
  end
end
