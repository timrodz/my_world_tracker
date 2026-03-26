defmodule WorldTracker.Locations.LocationsWorkerTest do
  use WorldTracker.DataCase, async: false
  use Oban.Testing, repo: WorldTracker.Repo

  import WorldTracker.LocationsFixtures

  alias WorldTracker.Locations
  alias WorldTracker.Workers.Locations, as: LocationsWorker

  setup do
    original_client = Application.get_env(:world_tracker, :overpass_client)

    Application.put_env(
      :world_tracker,
      :overpass_client,
      WorldTracker.Locations.OverpassClientStub
    )

    on_exit(fn ->
      case original_client do
        nil -> Application.delete_env(:world_tracker, :overpass_client)
        client -> Application.put_env(:world_tracker, :overpass_client, client)
      end
    end)

    :ok
  end

  test "enqueue/1 schedules the worker on the locations queue" do
    assert {:ok, _job} = LocationsWorker.enqueue()
    assert_enqueued(worker: LocationsWorker, queue: :locations)
  end

  test "perform/1 replaces all configured location types and broadcasts updates" do
    location_fixture(%{type: :data_center, name: "Old Data Center"})
    location_fixture(%{type: :oil_facility, name: "Old Oil Facility"})

    Phoenix.PubSub.subscribe(WorldTracker.PubSub, Locations.topic())

    assert :ok = perform_job(LocationsWorker, %{})

    data_centers = Locations.list_data_centers()
    oil_facilities = Locations.list_oil_facilities()
    ports = Locations.list_ports()
    airports = Locations.list_airports()
    military_bases = Locations.list_military_bases()

    assert Enum.any?(data_centers, &(&1.name == "Stub Data Center"))
    refute Enum.any?(data_centers, &(&1.name == "Old Data Center"))

    assert Enum.any?(oil_facilities, &(&1.name == "Stub Oil Facility"))
    refute Enum.any?(oil_facilities, &(&1.name == "Old Oil Facility"))

    assert Enum.any?(ports, &(&1.name == "Stub Port"))
    assert Enum.any?(airports, &(&1.name == "Stub Airport"))
    assert Enum.any?(military_bases, &(&1.name == "Stub Military Base"))

    assert_receive {:locations_updated, :data_center}
    assert_receive {:locations_updated, :oil_facility}
    assert_receive {:locations_updated, :port}
    assert_receive {:locations_updated, :airport}
    assert_receive {:locations_updated, :military_base}
  end
end
