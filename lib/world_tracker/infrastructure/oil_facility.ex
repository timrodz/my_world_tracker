defmodule WorldTracker.Infrastructure.OilFacility do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Countries.Country

  schema "oil_facilities" do
    field :name, :string
    field :facility_type, :string
    field :latitude, :float
    field :longitude, :float
    belongs_to :country, Country, foreign_key: :country_code, references: :alpha2, type: :string
    field :operator, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(oil_facility, attrs) do
    oil_facility
    |> cast(attrs, [:name, :facility_type, :latitude, :longitude, :country_code, :operator])
    |> validate_required([:name, :facility_type, :latitude, :longitude])
    |> assoc_constraint(:country)
  end
end
