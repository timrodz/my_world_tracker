defmodule WorldTracker.Infrastructure.OilFacility do
  use Ecto.Schema
  import Ecto.Changeset

  schema "oil_facilities" do
    field :name, :string
    field :facility_type, :string
    field :latitude, :float
    field :longitude, :float
    field :country_code, :string
    field :operator, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(oil_facility, attrs) do
    oil_facility
    |> cast(attrs, [:name, :facility_type, :latitude, :longitude, :country_code, :operator])
    |> validate_required([:name, :facility_type, :latitude, :longitude])
  end
end
