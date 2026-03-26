defmodule WorldTracker.LocationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorldTracker.Locations` context.
  """

  alias WorldTracker.Locations.Location
  alias WorldTracker.Repo

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        city: "Some city",
        latitude: 37.7749,
        longitude: -122.4194,
        name: "Location #{System.unique_integer([:positive])}",
        operator: "Some operator",
        subtype: "some_subtype",
        type: :data_center
      })

    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert!()
  end
end
