defmodule WorldTracker.Countries.CountryCode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "country_codes" do
    field :alpha2_code, :string

    belongs_to :country, WorldTracker.Countries.Country

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(country_code, attrs) do
    country_code
    |> cast(attrs, [:alpha2_code, :country_id])
    |> validate_required([:alpha2_code, :country_id])
    |> validate_length(:alpha2_code, is: 2)
    |> unique_constraint(:alpha2_code)
    |> unique_constraint(:country_id)
    |> assoc_constraint(:country)
  end
end
