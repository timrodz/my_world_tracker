defmodule WorldTracker.Countries.Country do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:alpha2, :string, []}
  schema "countries" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:alpha2, :name])
    |> validate_required([:alpha2, :name])
    |> validate_length(:alpha2, is: 2)
  end
end
