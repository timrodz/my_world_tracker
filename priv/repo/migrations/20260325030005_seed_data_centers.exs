defmodule WorldTracker.Repo.Migrations.SeedDataCenters do
  use Ecto.Migration

  import Ecto.Query

  @data_centers [
    # Amazon Web Services
    %{name: "AWS US East (N. Virginia)", operator: "Amazon Web Services", city: "Ashburn", country_code: "US", latitude: 38.894, longitude: -77.448},
    %{name: "AWS US West (Oregon)", operator: "Amazon Web Services", city: "Hillsboro", country_code: "US", latitude: 45.522, longitude: -122.989},
    %{name: "AWS EU West (Ireland)", operator: "Amazon Web Services", city: "Dublin", country_code: "IE", latitude: 53.345, longitude: -6.259},
    %{name: "AWS EU Central (Frankfurt)", operator: "Amazon Web Services", city: "Frankfurt", country_code: "DE", latitude: 50.109, longitude: 8.677},
    %{name: "AWS EU West 2 (London)", operator: "Amazon Web Services", city: "London", country_code: "GB", latitude: 51.507, longitude: -0.127},
    %{name: "AWS AP Northeast (Tokyo)", operator: "Amazon Web Services", city: "Tokyo", country_code: "JP", latitude: 35.652, longitude: 139.839},
    %{name: "AWS AP Southeast (Singapore)", operator: "Amazon Web Services", city: "Singapore", country_code: "SG", latitude: 1.35, longitude: 103.82},
    %{name: "AWS AP Southeast 2 (Sydney)", operator: "Amazon Web Services", city: "Sydney", country_code: "AU", latitude: -33.869, longitude: 151.209},
    %{name: "AWS AP South (Mumbai)", operator: "Amazon Web Services", city: "Mumbai", country_code: "IN", latitude: 19.076, longitude: 72.877},
    %{name: "AWS SA East (São Paulo)", operator: "Amazon Web Services", city: "São Paulo", country_code: "BR", latitude: -23.549, longitude: -46.633},
    %{name: "AWS CA Central (Montreal)", operator: "Amazon Web Services", city: "Montreal", country_code: "CA", latitude: 45.501, longitude: -73.567},
    %{name: "AWS ME South (Bahrain)", operator: "Amazon Web Services", city: "Manama", country_code: "BH", latitude: 26.066, longitude: 50.558},
    %{name: "AWS AF South (Cape Town)", operator: "Amazon Web Services", city: "Cape Town", country_code: "ZA", latitude: -33.925, longitude: 18.424},
    # Google Cloud
    %{name: "GCP US Central (Iowa)", operator: "Google Cloud", city: "Council Bluffs", country_code: "US", latitude: 41.262, longitude: -95.861},
    %{name: "GCP US East (South Carolina)", operator: "Google Cloud", city: "Moncks Corner", country_code: "US", latitude: 33.196, longitude: -80.012},
    %{name: "GCP EU West (Belgium)", operator: "Google Cloud", city: "St. Ghislain", country_code: "BE", latitude: 50.454, longitude: 3.778},
    %{name: "GCP EU North (Finland)", operator: "Google Cloud", city: "Hamina", country_code: "FI", latitude: 60.567, longitude: 27.197},
    %{name: "GCP Asia East (Taiwan)", operator: "Google Cloud", city: "Changhua County", country_code: "TW", latitude: 24.063, longitude: 120.516},
    %{name: "GCP Asia Southeast (Singapore)", operator: "Google Cloud", city: "Singapore", country_code: "SG", latitude: 1.352, longitude: 103.822},
    %{name: "GCP Asia South (Mumbai)", operator: "Google Cloud", city: "Mumbai", country_code: "IN", latitude: 19.079, longitude: 72.880},
    # Microsoft Azure
    %{name: "Azure East US (Virginia)", operator: "Microsoft Azure", city: "Boydton", country_code: "US", latitude: 36.669, longitude: -78.388},
    %{name: "Azure West US (California)", operator: "Microsoft Azure", city: "San Jose", country_code: "US", latitude: 37.338, longitude: -121.886},
    %{name: "Azure North Europe (Ireland)", operator: "Microsoft Azure", city: "Dublin", country_code: "IE", latitude: 53.347, longitude: -6.261},
    %{name: "Azure West Europe (Netherlands)", operator: "Microsoft Azure", city: "Amsterdam", country_code: "NL", latitude: 52.377, longitude: 4.897},
    %{name: "Azure Southeast Asia (Singapore)", operator: "Microsoft Azure", city: "Singapore", country_code: "SG", latitude: 1.353, longitude: 103.819},
    %{name: "Azure Japan East (Tokyo)", operator: "Microsoft Azure", city: "Tokyo", country_code: "JP", latitude: 35.654, longitude: 139.841},
    %{name: "Azure Brazil South (São Paulo)", operator: "Microsoft Azure", city: "São Paulo", country_code: "BR", latitude: -23.551, longitude: -46.635},
    %{name: "Azure Australia East (Sydney)", operator: "Microsoft Azure", city: "Sydney", country_code: "AU", latitude: -33.871, longitude: 151.207},
    %{name: "Azure UAE North (Dubai)", operator: "Microsoft Azure", city: "Dubai", country_code: "AE", latitude: 25.204, longitude: 55.270},
    # Equinix
    %{name: "Equinix LD5 (London)", operator: "Equinix", city: "London", country_code: "GB", latitude: 51.518, longitude: -0.081},
    %{name: "Equinix FR4 (Frankfurt)", operator: "Equinix", city: "Frankfurt", country_code: "DE", latitude: 50.116, longitude: 8.695},
    %{name: "Equinix AM3 (Amsterdam)", operator: "Equinix", city: "Amsterdam", country_code: "NL", latitude: 52.372, longitude: 4.898},
    %{name: "Equinix SG1 (Singapore)", operator: "Equinix", city: "Singapore", country_code: "SG", latitude: 1.354, longitude: 103.817},
    %{name: "Equinix TY2 (Tokyo)", operator: "Equinix", city: "Tokyo", country_code: "JP", latitude: 35.660, longitude: 139.845},
    %{name: "Equinix DC2 (Ashburn)", operator: "Equinix", city: "Ashburn", country_code: "US", latitude: 38.897, longitude: -77.446},
    %{name: "Equinix SY3 (Sydney)", operator: "Equinix", city: "Sydney", country_code: "AU", latitude: -33.877, longitude: 151.201}
  ]

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    alpha2_to_country_id =
      repo().all(from c in "countries", select: {c.alpha2_code, c.id})
      |> Map.new()

    rows =
      Enum.map(@data_centers, fn dc ->
        %{
          name: dc.name,
          type: "data_center",
          operator: dc.operator,
          city: dc.city,
          latitude: dc.latitude,
          longitude: dc.longitude,
          country_id: Map.get(alpha2_to_country_id, dc.country_code),
          inserted_at: now,
          updated_at: now
        }
      end)

    repo().insert_all("locations", rows, on_conflict: :nothing)
  end

  def down do
    names = Enum.map(@data_centers, & &1.name)

    repo().delete_all(
      from(l in "locations", where: l.name in ^names and l.type == "data_center")
    )
  end
end
