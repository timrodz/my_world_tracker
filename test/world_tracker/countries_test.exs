defmodule WorldTracker.CountriesTest do
  use WorldTracker.DataCase

  alias WorldTracker.Countries

  describe "countries" do
    alias WorldTracker.Countries.Country

    import WorldTracker.CountriesFixtures

    @invalid_attrs %{name: nil}

    test "list_countries/0 returns all countries" do
      country = country_fixture()
      assert country in Countries.list_countries()
    end

    test "get_country!/1 returns the country with given id" do
      country = country_fixture()
      assert Countries.get_country!(country.id) == country
    end

    test "create_country/1 with valid data creates a country and country_code" do
      valid_attrs = %{name: "some name", alpha2: "XX"}

      assert {:ok, %Country{} = country} = Countries.create_country(valid_attrs)
      assert country.name == "some name"
      assert country.country_code.alpha2_code == "XX"
    end

    test "create_country/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Countries.create_country(@invalid_attrs)
    end

    test "update_country/2 with valid data updates the country" do
      country = country_fixture()
      update_attrs = %{name: "some updated name", alpha2: "YY"}

      assert {:ok, %Country{} = country} = Countries.update_country(country, update_attrs)
      assert country.name == "some updated name"
      assert country.country_code.alpha2_code == "YY"
    end

    test "update_country/2 with invalid data returns error changeset" do
      country = country_fixture()
      assert {:error, %Ecto.Changeset{}} = Countries.update_country(country, @invalid_attrs)
      assert country == Countries.get_country!(country.id)
    end

    test "delete_country/1 deletes the country" do
      country = country_fixture()
      assert {:ok, %Country{}} = Countries.delete_country(country)
      assert_raise Ecto.NoResultsError, fn -> Countries.get_country!(country.id) end
    end

    test "change_country/1 returns a country changeset" do
      country = country_fixture()
      assert %Ecto.Changeset{} = Countries.change_country(country)
    end
  end
end
