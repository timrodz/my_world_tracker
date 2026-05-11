defmodule WorldTracker.Locations.OverpassClient do
  @moduledoc """
  Fetches worldwide location datasets from the Overpass API.
  """

  @endpoint "https://overpass-api.de/api/interpreter"

  def fetch_locations(type)
      when type in [:data_center, :oil_facility, :port, :airport, :military_base] do
    query = overpass_query(type)

    case Req.post(@endpoint, form: [data: query], receive_timeout: 120_000) do
      {:ok, %{status: 200, body: body}} ->
        parse_body(type, body)

      {:ok, %{status: status}} ->
        {:error, "unexpected HTTP status #{status} for overpass query type=#{type}"}

      {:error, reason} ->
        {:error, "HTTP request failed for overpass query type=#{type}: #{inspect(reason)}"}
    end
  end

  defp parse_body(type, %{"elements" => elements}) when is_list(elements) do
    locations =
      elements
      |> Enum.map(&to_location_attrs(type, &1))
      |> Enum.reject(&is_nil/1)
      |> dedupe_locations()

    {:ok, locations}
  end

  defp parse_body(_type, _body), do: {:error, "unexpected Overpass response payload"}

  defp to_location_attrs(type, element) do
    tags = Map.get(element, "tags", %{})
    {latitude, longitude} = element_coordinates(element)

    if is_nil(latitude) or is_nil(longitude) do
      nil
    else
      %{
        name: location_name(type, element, tags),
        subtype: location_subtype(type, tags),
        operator: clean_string(tags["operator"]),
        city: clean_string(tags["addr:city"]),
        latitude: latitude,
        longitude: longitude
      }
    end
  end

  defp element_coordinates(%{"lat" => lat, "lon" => lon}) when is_number(lat) and is_number(lon),
    do: {lat, lon}

  defp element_coordinates(%{"center" => %{"lat" => lat, "lon" => lon}})
       when is_number(lat) and is_number(lon),
       do: {lat, lon}

  defp element_coordinates(_), do: {nil, nil}

  defp location_name(type, element, tags) do
    clean_string(tags["name"]) ||
      "#{type_label(type)} #{Map.get(element, "type", "element")}-#{Map.get(element, "id")}"
  end

  defp type_label(:data_center), do: "Data Center"
  defp type_label(:oil_facility), do: "Oil Facility"
  defp type_label(:port), do: "Port"
  defp type_label(:airport), do: "Airport"
  defp type_label(:military_base), do: "Military Base"

  defp location_subtype(:data_center, tags), do: clean_string(tags["telecom"])

  defp location_subtype(:oil_facility, tags) do
    clean_string(tags["man_made"]) || clean_string(tags["industrial"]) ||
      clean_string(tags["product"])
  end

  defp location_subtype(:port, tags) do
    clean_string(tags["harbour:category"]) || clean_string(tags["industrial"]) ||
      clean_string(tags["landuse"])
  end

  defp location_subtype(:airport, tags), do: clean_string(tags["aeroway"])

  defp location_subtype(:military_base, tags) do
    clean_string(tags["military"]) || clean_string(tags["landuse"])
  end

  defp clean_string(value) when is_binary(value) do
    value = String.trim(value)
    if value == "", do: nil, else: value
  end

  defp clean_string(_), do: nil

  defp dedupe_locations(locations) do
    locations
    |> Enum.uniq_by(fn location ->
      {
        location.name,
        location.latitude,
        location.longitude
      }
    end)
  end

  defp overpass_query(:data_center) do
    """
    [out:json][timeout:120];
    (
      node["telecom"="data_center"];
      way["telecom"="data_center"];
      relation["telecom"="data_center"];
    );
    out center;
    """
  end

  defp overpass_query(:oil_facility) do
    """
    [out:json][timeout:120];
    (
      node["man_made"~"petroleum_well|offshore_platform|works"];
      way["man_made"~"petroleum_well|offshore_platform|works"];
      relation["man_made"~"petroleum_well|offshore_platform|works"];
      node["industrial"~"oil|refinery|gas"];
      way["industrial"~"oil|refinery|gas"];
      relation["industrial"~"oil|refinery|gas"];
      node["product"~"oil|petroleum|fuel|lng"];
      way["product"~"oil|petroleum|fuel|lng"];
      relation["product"~"oil|petroleum|fuel|lng"];
    );
    out center;
    """
  end

  defp overpass_query(:port) do
    """
    [out:json][timeout:120];
    (
      node["landuse"="port"];
      way["landuse"="port"];
      relation["landuse"="port"];
      node["harbour:category"~"commercial|cargo|container"];
      way["harbour:category"~"commercial|cargo|container"];
      relation["harbour:category"~"commercial|cargo|container"];
      node["industrial"="port"];
      way["industrial"="port"];
      relation["industrial"="port"];
    );
    out center;
    """
  end

  defp overpass_query(:airport) do
    """
    [out:json][timeout:120];
    (
      node["aeroway"="aerodrome"]["iata"];
      way["aeroway"="aerodrome"]["iata"];
      relation["aeroway"="aerodrome"]["iata"];
    );
    out center;
    """
  end

  defp overpass_query(:military_base) do
    """
    [out:json][timeout:120];
    (
      node["military"="base"];
      way["military"="base"];
      relation["military"="base"];
      node["landuse"="military"];
      way["landuse"="military"];
      relation["landuse"="military"];
    );
    out center;
    """
  end
end
