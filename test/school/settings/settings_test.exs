defmodule School.SettingsTest do
  use School.DataCase

  alias School.Settings

  describe "parameters" do
    alias School.Settings.Parameter

    @valid_attrs %{blood_type: "some blood_type", career: "some career", nationality: "some nationality", oku: "some oku", race: "some race", religion: "some religion", sickness: "some sickness", transport: "some transport"}
    @update_attrs %{blood_type: "some updated blood_type", career: "some updated career", nationality: "some updated nationality", oku: "some updated oku", race: "some updated race", religion: "some updated religion", sickness: "some updated sickness", transport: "some updated transport"}
    @invalid_attrs %{blood_type: nil, career: nil, nationality: nil, oku: nil, race: nil, religion: nil, sickness: nil, transport: nil}

    def parameter_fixture(attrs \\ %{}) do
      {:ok, parameter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_parameter()

      parameter
    end

    test "list_parameters/0 returns all parameters" do
      parameter = parameter_fixture()
      assert Settings.list_parameters() == [parameter]
    end

    test "get_parameter!/1 returns the parameter with given id" do
      parameter = parameter_fixture()
      assert Settings.get_parameter!(parameter.id) == parameter
    end

    test "create_parameter/1 with valid data creates a parameter" do
      assert {:ok, %Parameter{} = parameter} = Settings.create_parameter(@valid_attrs)
      assert parameter.blood_type == "some blood_type"
      assert parameter.career == "some career"
      assert parameter.nationality == "some nationality"
      assert parameter.oku == "some oku"
      assert parameter.race == "some race"
      assert parameter.religion == "some religion"
      assert parameter.sickness == "some sickness"
      assert parameter.transport == "some transport"
    end

    test "create_parameter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_parameter(@invalid_attrs)
    end

    test "update_parameter/2 with valid data updates the parameter" do
      parameter = parameter_fixture()
      assert {:ok, parameter} = Settings.update_parameter(parameter, @update_attrs)
      assert %Parameter{} = parameter
      assert parameter.blood_type == "some updated blood_type"
      assert parameter.career == "some updated career"
      assert parameter.nationality == "some updated nationality"
      assert parameter.oku == "some updated oku"
      assert parameter.race == "some updated race"
      assert parameter.religion == "some updated religion"
      assert parameter.sickness == "some updated sickness"
      assert parameter.transport == "some updated transport"
    end

    test "update_parameter/2 with invalid data returns error changeset" do
      parameter = parameter_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_parameter(parameter, @invalid_attrs)
      assert parameter == Settings.get_parameter!(parameter.id)
    end

    test "delete_parameter/1 deletes the parameter" do
      parameter = parameter_fixture()
      assert {:ok, %Parameter{}} = Settings.delete_parameter(parameter)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_parameter!(parameter.id) end
    end

    test "change_parameter/1 returns a parameter changeset" do
      parameter = parameter_fixture()
      assert %Ecto.Changeset{} = Settings.change_parameter(parameter)
    end
  end

  describe "schools" do
    alias School.Settings.School

    @valid_attrs %{countryphone: "some countryphone", email: "some email", email2: "some email2", fax: "some fax", fax2: "some fax2", line1: "some line1", line2: "some line2", logo_bin: "some logo_bin", logo_filename: "some logo_filename", name: "some name", phone2: "some phone2", postcode: "some postcode", state: "some state", town: "some town"}
    @update_attrs %{countryphone: "some updated countryphone", email: "some updated email", email2: "some updated email2", fax: "some updated fax", fax2: "some updated fax2", line1: "some updated line1", line2: "some updated line2", logo_bin: "some updated logo_bin", logo_filename: "some updated logo_filename", name: "some updated name", phone2: "some updated phone2", postcode: "some updated postcode", state: "some updated state", town: "some updated town"}
    @invalid_attrs %{countryphone: nil, email: nil, email2: nil, fax: nil, fax2: nil, line1: nil, line2: nil, logo_bin: nil, logo_filename: nil, name: nil, phone2: nil, postcode: nil, state: nil, town: nil}

    def school_fixture(attrs \\ %{}) do
      {:ok, school} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_school()

      school
    end

    test "list_schools/0 returns all schools" do
      school = school_fixture()
      assert Settings.list_schools() == [school]
    end

    test "get_school!/1 returns the school with given id" do
      school = school_fixture()
      assert Settings.get_school!(school.id) == school
    end

    test "create_school/1 with valid data creates a school" do
      assert {:ok, %School{} = school} = Settings.create_school(@valid_attrs)
      assert school.countryphone == "some countryphone"
      assert school.email == "some email"
      assert school.email2 == "some email2"
      assert school.fax == "some fax"
      assert school.fax2 == "some fax2"
      assert school.line1 == "some line1"
      assert school.line2 == "some line2"
      assert school.logo_bin == "some logo_bin"
      assert school.logo_filename == "some logo_filename"
      assert school.name == "some name"
      assert school.phone2 == "some phone2"
      assert school.postcode == "some postcode"
      assert school.state == "some state"
      assert school.town == "some town"
    end

    test "create_school/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_school(@invalid_attrs)
    end

    test "update_school/2 with valid data updates the school" do
      school = school_fixture()
      assert {:ok, school} = Settings.update_school(school, @update_attrs)
      assert %School{} = school
      assert school.countryphone == "some updated countryphone"
      assert school.email == "some updated email"
      assert school.email2 == "some updated email2"
      assert school.fax == "some updated fax"
      assert school.fax2 == "some updated fax2"
      assert school.line1 == "some updated line1"
      assert school.line2 == "some updated line2"
      assert school.logo_bin == "some updated logo_bin"
      assert school.logo_filename == "some updated logo_filename"
      assert school.name == "some updated name"
      assert school.phone2 == "some updated phone2"
      assert school.postcode == "some updated postcode"
      assert school.state == "some updated state"
      assert school.town == "some updated town"
    end

    test "update_school/2 with invalid data returns error changeset" do
      school = school_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_school(school, @invalid_attrs)
      assert school == Settings.get_school!(school.id)
    end

    test "delete_school/1 deletes the school" do
      school = school_fixture()
      assert {:ok, %School{}} = Settings.delete_school(school)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_school!(school.id) end
    end

    test "change_school/1 returns a school changeset" do
      school = school_fixture()
      assert %Ecto.Changeset{} = Settings.change_school(school)
    end
  end

  describe "institutions" do
    alias School.Settings.Institution

    @valid_attrs %{country: "some country", email: "some email", email2: "some email2", fax: "some fax", line1: "some line1", line2: "some line2", logo_bin: "some logo_bin", logo_filename: "some logo_filename", name: "some name", phone: "some phone", phone2: "some phone2", postcode: "some postcode", state: "some state", town: "some town"}
    @update_attrs %{country: "some updated country", email: "some updated email", email2: "some updated email2", fax: "some updated fax", line1: "some updated line1", line2: "some updated line2", logo_bin: "some updated logo_bin", logo_filename: "some updated logo_filename", name: "some updated name", phone: "some updated phone", phone2: "some updated phone2", postcode: "some updated postcode", state: "some updated state", town: "some updated town"}
    @invalid_attrs %{country: nil, email: nil, email2: nil, fax: nil, line1: nil, line2: nil, logo_bin: nil, logo_filename: nil, name: nil, phone: nil, phone2: nil, postcode: nil, state: nil, town: nil}

    def institution_fixture(attrs \\ %{}) do
      {:ok, institution} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_institution()

      institution
    end

    test "list_institutions/0 returns all institutions" do
      institution = institution_fixture()
      assert Settings.list_institutions() == [institution]
    end

    test "get_institution!/1 returns the institution with given id" do
      institution = institution_fixture()
      assert Settings.get_institution!(institution.id) == institution
    end

    test "create_institution/1 with valid data creates a institution" do
      assert {:ok, %Institution{} = institution} = Settings.create_institution(@valid_attrs)
      assert institution.country == "some country"
      assert institution.email == "some email"
      assert institution.email2 == "some email2"
      assert institution.fax == "some fax"
      assert institution.line1 == "some line1"
      assert institution.line2 == "some line2"
      assert institution.logo_bin == "some logo_bin"
      assert institution.logo_filename == "some logo_filename"
      assert institution.name == "some name"
      assert institution.phone == "some phone"
      assert institution.phone2 == "some phone2"
      assert institution.postcode == "some postcode"
      assert institution.state == "some state"
      assert institution.town == "some town"
    end

    test "create_institution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_institution(@invalid_attrs)
    end

    test "update_institution/2 with valid data updates the institution" do
      institution = institution_fixture()
      assert {:ok, institution} = Settings.update_institution(institution, @update_attrs)
      assert %Institution{} = institution
      assert institution.country == "some updated country"
      assert institution.email == "some updated email"
      assert institution.email2 == "some updated email2"
      assert institution.fax == "some updated fax"
      assert institution.line1 == "some updated line1"
      assert institution.line2 == "some updated line2"
      assert institution.logo_bin == "some updated logo_bin"
      assert institution.logo_filename == "some updated logo_filename"
      assert institution.name == "some updated name"
      assert institution.phone == "some updated phone"
      assert institution.phone2 == "some updated phone2"
      assert institution.postcode == "some updated postcode"
      assert institution.state == "some updated state"
      assert institution.town == "some updated town"
    end

    test "update_institution/2 with invalid data returns error changeset" do
      institution = institution_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_institution(institution, @invalid_attrs)
      assert institution == Settings.get_institution!(institution.id)
    end

    test "delete_institution/1 deletes the institution" do
      institution = institution_fixture()
      assert {:ok, %Institution{}} = Settings.delete_institution(institution)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_institution!(institution.id) end
    end

    test "change_institution/1 returns a institution changeset" do
      institution = institution_fixture()
      assert %Ecto.Changeset{} = Settings.change_institution(institution)
    end
  end

  describe "users" do
    alias School.Settings.User

    @valid_attrs %{crypted_password: "some crypted_password", institution_id: 42, name: "some name", password: "some password", role: "some role"}
    @update_attrs %{crypted_password: "some updated crypted_password", institution_id: 43, name: "some updated name", password: "some updated password", role: "some updated role"}
    @invalid_attrs %{crypted_password: nil, institution_id: nil, name: nil, password: nil, role: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Settings.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Settings.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Settings.create_user(@valid_attrs)
      assert user.crypted_password == "some crypted_password"
      assert user.institution_id == 42
      assert user.name == "some name"
      assert user.password == "some password"
      assert user.role == "some role"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Settings.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.crypted_password == "some updated crypted_password"
      assert user.institution_id == 43
      assert user.name == "some updated name"
      assert user.password == "some updated password"
      assert user.role == "some updated role"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_user(user, @invalid_attrs)
      assert user == Settings.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Settings.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Settings.change_user(user)
    end
  end

  describe "labels" do
    alias School.Settings.Label

    @valid_attrs %{bm: "some bm", cn: "some cn", en: "some en", name: "some name"}
    @update_attrs %{bm: "some updated bm", cn: "some updated cn", en: "some updated en", name: "some updated name"}
    @invalid_attrs %{bm: nil, cn: nil, en: nil, name: nil}

    def label_fixture(attrs \\ %{}) do
      {:ok, label} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_label()

      label
    end

    test "list_labels/0 returns all labels" do
      label = label_fixture()
      assert Settings.list_labels() == [label]
    end

    test "get_label!/1 returns the label with given id" do
      label = label_fixture()
      assert Settings.get_label!(label.id) == label
    end

    test "create_label/1 with valid data creates a label" do
      assert {:ok, %Label{} = label} = Settings.create_label(@valid_attrs)
      assert label.bm == "some bm"
      assert label.cn == "some cn"
      assert label.en == "some en"
      assert label.name == "some name"
    end

    test "create_label/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_label(@invalid_attrs)
    end

    test "update_label/2 with valid data updates the label" do
      label = label_fixture()
      assert {:ok, label} = Settings.update_label(label, @update_attrs)
      assert %Label{} = label
      assert label.bm == "some updated bm"
      assert label.cn == "some updated cn"
      assert label.en == "some updated en"
      assert label.name == "some updated name"
    end

    test "update_label/2 with invalid data returns error changeset" do
      label = label_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_label(label, @invalid_attrs)
      assert label == Settings.get_label!(label.id)
    end

    test "delete_label/1 deletes the label" do
      label = label_fixture()
      assert {:ok, %Label{}} = Settings.delete_label(label)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_label!(label.id) end
    end

    test "change_label/1 returns a label changeset" do
      label = label_fixture()
      assert %Ecto.Changeset{} = Settings.change_label(label)
    end
  end
end
