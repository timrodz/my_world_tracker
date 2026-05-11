defmodule WorldTracker.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :type, Ecto.Enum, values: [:data_center, :oil_facility, :port, :airport, :military_base]
    field :subtype, :string
    field :operator, :string
    field :latitude, :float
    field :longitude, :float
    field :city, :string

    belongs_to :country, WorldTracker.Countries.Country

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :type, :subtype, :operator, :latitude, :longitude, :city, :country_id])
    |> validate_required([:name, :type, :latitude, :longitude])
  end
end
