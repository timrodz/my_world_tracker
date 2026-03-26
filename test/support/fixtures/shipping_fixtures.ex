defmodule WorldTracker.ShippingFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WorldTracker.Shipping` context.
  """

  alias WorldTracker.Repo

  def data_source_fixture(attrs \\ %{}) do
    {:ok, ds} =
      attrs
      |> Enum.into(%{
        name: "AISStream",
        slug: "aisstream-#{System.unique_integer([:positive])}",
        base_url: "wss://stream.aisstream.io",
        type: :locations,
        endpoint_url: "/v0/stream"
      })
      |> WorldTracker.Sources.create_data_source()

    ds
  end

  def ship_fixture(attrs \\ %{}) do
    ds = data_source_fixture()

    {:ok, ship} =
      attrs
      |> Enum.into(%{
        mmsi: 100_000_000 + rem(System.unique_integer([:positive, :monotonic]), 899_999_999),
        name: "Test Vessel",
        latitude: 51.5,
        longitude: -0.12,
        speed: 12.0,
        course: 90.0,
        last_seen_at: DateTime.utc_now() |> DateTime.truncate(:second),
        data_source_id: ds.id
      })
      |> WorldTracker.Shipping.upsert_ship()

    Repo.preload(ship, :data_source)
  end
end
