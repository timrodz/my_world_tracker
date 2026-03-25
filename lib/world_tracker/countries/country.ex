defmodule WorldTracker.Countries.Country do
  use Ecto.Schema
  import Ecto.Changeset

  schema "countries" do
    field :name, :string

    has_one :country_code, WorldTracker.Countries.CountryCode

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
