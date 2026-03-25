defmodule WorldTracker.ShippingTest do
  use WorldTracker.DataCase, async: true

  alias WorldTracker.Shipping
  alias WorldTracker.Shipping.Ship

  import WorldTracker.ShippingFixtures

  describe "list_ships/0" do
    test "returns all ships" do
      ship = ship_fixture()
      ids = Shipping.list_ships() |> Enum.map(& &1.id)
      assert ship.id in ids
    end

    test "returns empty list when no ships" do
      assert Shipping.list_ships() == []
    end
  end

  describe "upsert_ship/1" do
    test "inserts a new ship with valid attrs" do
      ds = data_source_fixture()

      attrs = %{
        mmsi: 123_456_789,
        name: "MY VESSEL",
        latitude: 51.5,
        longitude: -0.12,
        speed: 10.5,
        course: 45.0,
        data_source_id: ds.id
      }

      assert {:ok, %Ship{} = ship} = Shipping.upsert_ship(attrs)
      assert ship.mmsi == 123_456_789
      assert ship.name == "MY VESSEL"
      assert ship.latitude == 51.5
    end

    test "updates existing ship on mmsi conflict" do
      ds = data_source_fixture()
      mmsi = 987_654_321

      {:ok, _ship} =
        Shipping.upsert_ship(%{mmsi: mmsi, latitude: 10.0, longitude: 20.0, data_source_id: ds.id})

      {:ok, updated} =
        Shipping.upsert_ship(%{mmsi: mmsi, latitude: 15.0, longitude: 25.0, data_source_id: ds.id})

      assert updated.latitude == 15.0
      assert updated.longitude == 25.0
      assert Repo.aggregate(Ship, :count, :id) == 1
    end

    test "returns error changeset for missing mmsi" do
      ds = data_source_fixture()
      assert {:error, changeset} = Shipping.upsert_ship(%{data_source_id: ds.id})
      assert %{mmsi: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error changeset for missing data_source_id" do
      assert {:error, changeset} = Shipping.upsert_ship(%{mmsi: 111_222_333})
      assert %{data_source_id: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "topic/0" do
    test "returns the ships PubSub topic string" do
      assert Shipping.topic() == "ships"
    end
  end
end
