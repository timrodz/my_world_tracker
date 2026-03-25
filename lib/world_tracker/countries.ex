defmodule WorldTracker.Countries do
  @moduledoc """
  The Countries context.
  """

  import Ecto.Query, warn: false
  alias WorldTracker.Repo

  alias WorldTracker.Countries.Country

  @doc """
  Returns the list of countries.
  """
  def list_countries do
    Repo.all(Country)
  end

  @doc """
  Gets a single country by integer id.

  Raises `Ecto.NoResultsError` if the Country does not exist.
  """
  def get_country!(id), do: Repo.get!(Country, id)

  @doc """
  Gets a single country by alpha2 code.
  Returns `nil` if no country has that alpha2 code.
  """
  def get_country_by_alpha2(alpha2_code) do
    Repo.one(from c in Country, where: c.alpha2_code == ^alpha2_code)
  end

  @doc """
  Creates a country.
  Accepts `alpha2` or `alpha2_code` in attrs for the country code.
  """
  def create_country(attrs) do
    %Country{}
    |> Country.changeset(normalize_attrs(attrs))
    |> Repo.insert()
  end

  @doc """
  Updates a country.
  Accepts `alpha2` or `alpha2_code` in attrs for the country code.
  """
  def update_country(%Country{} = country, attrs) do
    country
    |> Country.changeset(normalize_attrs(attrs))
    |> Repo.update()
  end

  @doc """
  Deletes a country.
  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.
  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, normalize_attrs(attrs))
  end

  # Normalise attrs so callers can pass :alpha2 or :alpha2_code (atom or string keys).
  defp normalize_attrs(attrs) do
    alpha2 =
      attrs[:alpha2_code] || attrs[:alpha2] ||
        attrs["alpha2_code"] || attrs["alpha2"]

    string_attrs = Map.new(attrs, fn {k, v} -> {to_string(k), v} end)

    if alpha2 do
      Map.put(string_attrs, "alpha2_code", alpha2)
    else
      string_attrs
    end
  end
end
