defmodule WorldTracker.Countries.Country do
  use Ecto.Schema
  import Ecto.Changeset

  schema "countries" do
    field :name, :string
    field :alpha2_code, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name, :alpha2_code])
    |> validate_required([:name, :alpha2_code])
    |> validate_length(:alpha2_code, is: 2)
    |> unique_constraint(:alpha2_code)
  end
end
