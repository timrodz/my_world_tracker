defmodule WorldTracker.Infrastructure.DataCenter do
  use Ecto.Schema
  import Ecto.Changeset

  alias WorldTracker.Countries.Country

  schema "data_centers" do
    field :name, :string
    field :operator, :string
    field :latitude, :float
    field :longitude, :float
    field :city, :string
    belongs_to :country, Country, foreign_key: :country_code, references: :alpha2, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(data_center, attrs) do
    data_center
    |> cast(attrs, [:name, :operator, :latitude, :longitude, :city, :country_code])
    |> validate_required([:name, :operator, :latitude, :longitude])
    |> assoc_constraint(:country)
  end
end
