defmodule WorldTracker.CountriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorldTracker.Countries` context.
  """

  @doc """
  Generate a country.
  """
  def country_fixture(attrs \\ %{}) do
    {:ok, country} =
      attrs
      |> Enum.into(%{
        alpha2: "XX",
        name: "some name"
      })
      |> WorldTracker.Countries.create_country()

    country
  end
end
