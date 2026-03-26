defmodule WorldTracker.Shipping.Ship do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Sources.DataSource

  schema "ships" do
    field :mmsi, :integer
    field :name, :string
    field :latitude, :float
    field :longitude, :float
    field :speed, :float
    field :course, :float
    field :ship_type, :integer
    field :flag, :string
    field :destination, :string
    field :last_seen_at, :utc_datetime

    belongs_to :data_source, DataSource

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ship, attrs) do
    ship
    |> cast(attrs, [
      :mmsi,
      :name,
      :latitude,
      :longitude,
      :speed,
      :course,
      :ship_type,
      :flag,
      :destination,
      :last_seen_at,
      :data_source_id
    ])
    |> validate_required([:mmsi, :data_source_id])
    |> unique_constraint(:mmsi)
    |> assoc_constraint(:data_source)
  end
end
