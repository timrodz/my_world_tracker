defmodule WorldTracker.Repo.Migrations.SeedOilFacilities do
  use Ecto.Migration

  import Ecto.Query

  @oil_facilities [
    # Major oil fields
    %{name: "Ghawar Oil Field", facility_type: "oil_field", operator: "Aramco", country_code: "SA", latitude: 24.889, longitude: 49.175},
    %{name: "Rumaila Oil Field", facility_type: "oil_field", operator: "Basra Oil Company", country_code: "IQ", latitude: 30.022, longitude: 47.525},
    %{name: "Burgan Oil Field", facility_type: "oil_field", operator: "Kuwait Oil Company", country_code: "KW", latitude: 29.022, longitude: 47.943},
    %{name: "Ahvaz Oil Field", facility_type: "oil_field", operator: "NIOC", country_code: "IR", latitude: 31.438, longitude: 49.688},
    %{name: "Permian Basin", facility_type: "oil_field", operator: "Multiple", country_code: "US", latitude: 31.831, longitude: -102.118},
    %{name: "Prudhoe Bay Oil Field", facility_type: "oil_field", operator: "BP / ConocoPhillips", country_code: "US", latitude: 70.255, longitude: -148.337},
    %{name: "Johan Sverdrup Field", facility_type: "oil_field", operator: "Equinor", country_code: "NO", latitude: 58.844, longitude: 2.663},
    %{name: "Cantarell Complex", facility_type: "oil_field", operator: "Pemex", country_code: "MX", latitude: 19.716, longitude: -91.884},
    %{name: "Orinoco Belt", facility_type: "oil_field", operator: "PDVSA", country_code: "VE", latitude: 8.195, longitude: -63.766},
    %{name: "Kashagan Oil Field", facility_type: "oil_field", operator: "NCOC", country_code: "KZ", latitude: 45.468, longitude: 53.052},
    %{name: "Tengiz Oil Field", facility_type: "oil_field", operator: "TengizChevroil", country_code: "KZ", latitude: 45.466, longitude: 53.148},
    %{name: "Buzios Pre-Salt Field", facility_type: "oil_field", operator: "Petrobras", country_code: "BR", latitude: -22.884, longitude: -40.886},
    # Major refineries
    %{name: "Port Arthur Refinery", facility_type: "refinery", operator: "Motiva Enterprises", country_code: "US", latitude: 29.885, longitude: -93.930},
    %{name: "Ruwais Refinery", facility_type: "refinery", operator: "ADNOC", country_code: "AE", latitude: 24.113, longitude: 52.737},
    %{name: "Jamnagar Refinery", facility_type: "refinery", operator: "Reliance Industries", country_code: "IN", latitude: 22.467, longitude: 70.074},
    %{name: "Rotterdam Refinery Complex", facility_type: "refinery", operator: "Shell / BP", country_code: "NL", latitude: 51.908, longitude: 4.270},
    %{name: "Ulsan Refinery", facility_type: "refinery", operator: "SK Innovation", country_code: "KR", latitude: 35.534, longitude: 129.319},
    %{name: "Ras Tanura Refinery", facility_type: "refinery", operator: "Aramco", country_code: "SA", latitude: 26.626, longitude: 50.158},
    %{name: "Jurong Island Refinery", facility_type: "refinery", operator: "ExxonMobil", country_code: "SG", latitude: 1.266, longitude: 103.702},
    %{name: "Bandar Abbas Refinery", facility_type: "refinery", operator: "NIOC", country_code: "IR", latitude: 27.183, longitude: 56.270},
    # LNG terminals
    %{name: "Ras Laffan LNG Terminal", facility_type: "lng_terminal", operator: "QatarEnergy", country_code: "QA", latitude: 25.976, longitude: 51.579},
    %{name: "Bonny LNG Terminal", facility_type: "lng_terminal", operator: "NLNG", country_code: "NG", latitude: 4.441, longitude: 7.156},
    %{name: "Darwin LNG Terminal", facility_type: "lng_terminal", operator: "Santos", country_code: "AU", latitude: -12.461, longitude: 130.819},
    %{name: "Sabine Pass LNG Terminal", facility_type: "lng_terminal", operator: "Cheniere Energy", country_code: "US", latitude: 29.725, longitude: -93.890},
    %{name: "Ichthys LNG Terminal", facility_type: "lng_terminal", operator: "INPEX", country_code: "AU", latitude: -12.462, longitude: 130.820},
    # Offshore platforms
    %{name: "Hibernia Platform", facility_type: "offshore_platform", operator: "ExxonMobil", country_code: "CA", latitude: 46.749, longitude: -48.774},
    %{name: "Bonga FPSO", facility_type: "offshore_platform", operator: "Shell Nigeria", country_code: "NG", latitude: 3.527, longitude: 4.851},
    %{name: "Johan Castberg FPSO", facility_type: "offshore_platform", operator: "Equinor", country_code: "NO", latitude: 72.000, longitude: 21.000}
  ]

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(@oil_facilities, fn facility ->
        Map.merge(facility, %{inserted_at: now, updated_at: now})
      end)

    repo().insert_all("oil_facilities", rows, on_conflict: :nothing)
  end

  def down do
    names = Enum.map(@oil_facilities, & &1.name)
    repo().delete_all(from(f in "oil_facilities", where: f.name in ^names))
  end
end
