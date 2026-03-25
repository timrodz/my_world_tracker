defmodule WorldTracker.Countries do
  @moduledoc """
  The Countries context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias WorldTracker.Repo

  alias WorldTracker.Countries.Country
  alias WorldTracker.Countries.CountryCode

  @doc """
  Returns the list of countries (with preloaded country_code).
  """
  def list_countries do
    Country
    |> preload(:country_code)
    |> Repo.all()
  end

  @doc """
  Gets a single country by integer id (with preloaded country_code).

  Raises `Ecto.NoResultsError` if the Country does not exist.
  """
  def get_country!(id) do
    Country
    |> preload(:country_code)
    |> Repo.get!(id)
  end

  @doc """
  Gets a single country by alpha2 code (with preloaded country_code).
  Returns `nil` if no country has that alpha2 code.
  """
  def get_country_by_alpha2(alpha2_code) do
    Repo.one(
      from c in Country,
        join: cc in CountryCode,
        on: cc.country_id == c.id,
        where: cc.alpha2_code == ^alpha2_code,
        preload: [country_code: cc]
    )
  end

  @doc """
  Creates a country and its associated country_code in a single transaction.
  Accepts `alpha2` or `alpha2_code` in attrs for the country code.
  """
  def create_country(attrs) do
    name = fetch_attr(attrs, [:name])
    alpha2 = fetch_attr(attrs, [:alpha2_code, :alpha2])

    Multi.new()
    |> Multi.insert(:country, Country.changeset(%Country{}, %{name: name}))
    |> Multi.insert(:country_code, fn %{country: country} ->
      CountryCode.changeset(%CountryCode{}, %{country_id: country.id, alpha2_code: alpha2})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{country: country}} -> {:ok, Repo.preload(country, :country_code)}
      {:error, _op, changeset, _changes} -> {:error, changeset}
    end
  end

  @doc """
  Updates a country name and/or its alpha2 code.
  Accepts `alpha2` or `alpha2_code` in attrs for the country code.
  """
  def update_country(%Country{} = country, attrs) do
    name = fetch_attr(attrs, [:name])
    alpha2 = fetch_attr(attrs, [:alpha2_code, :alpha2])

    country = Repo.preload(country, :country_code)

    multi =
      Multi.new()
      |> Multi.update(:country, Country.changeset(country, %{name: name}))

    multi =
      if alpha2 do
        Multi.update(multi, :country_code, fn %{country: updated_country} ->
          code = updated_country.country_code || %CountryCode{country_id: updated_country.id}
          CountryCode.changeset(code, %{alpha2_code: alpha2, country_id: updated_country.id})
        end)
      else
        multi
      end

    multi
    |> Repo.transaction()
    |> case do
      {:ok, %{country: country}} -> {:ok, Repo.preload(country, :country_code, force: true)}
      {:error, _op, changeset, _changes} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a country (cascade deletes its country_code).
  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.
  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, attrs)
  end

  # Fetches the first matching key from attrs, checking both atom and string versions.
  defp fetch_attr(attrs, keys) do
    Enum.find_value(keys, fn key ->
      attrs[key] || attrs[to_string(key)]
    end)
  end
end
