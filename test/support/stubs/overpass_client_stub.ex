defmodule WorldTracker.Locations.OverpassClientStub do
  def fetch_locations(type) do
    case Process.get({__MODULE__, type}) do
      nil -> {:ok, default_locations(type)}
      response -> response
    end
  end

  def put_response(type, response) do
    Process.put({__MODULE__, type}, response)
  end

  defp default_locations(:data_center) do
    [
      %{
        name: "Stub Data Center",
        subtype: "data_center",
        operator: "Stub Operator",
        city: "Stub City",
        latitude: 37.7749,
        longitude: -122.4194
      }
    ]
  end

  defp default_locations(:oil_facility) do
    [
      %{
        name: "Stub Oil Facility",
        subtype: "refinery",
        operator: "Stub Energy",
        city: "Stub Oil City",
        latitude: 29.7604,
        longitude: -95.3698
      }
    ]
  end

  defp default_locations(:port) do
    [
      %{
        name: "Stub Port",
        subtype: "commercial",
        operator: "Stub Port Authority",
        city: "Stub Harbor",
        latitude: 1.2903,
        longitude: 103.8519
      }
    ]
  end

  defp default_locations(:airport) do
    [
      %{
        name: "Stub Airport",
        subtype: "aerodrome",
        operator: "Stub Aviation",
        city: "Stub Airport City",
        latitude: 51.47,
        longitude: -0.4543
      }
    ]
  end

  defp default_locations(:military_base) do
    [
      %{
        name: "Stub Military Base",
        subtype: "base",
        operator: "Stub Defense",
        city: "Stub Base City",
        latitude: 34.0522,
        longitude: -118.2437
      }
    ]
  end
end
