defmodule WorldTracker.MarketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorldTracker.Markets` context.
  """

  import WorldTracker.SourcesFixtures

  @doc """
  Generate a ticker.
  """
  def ticker_fixture(attrs \\ %{}) do
    data_source = Map.get(attrs, :data_source) || data_source_fixture()

    {:ok, ticker} =
      attrs
      |> Enum.into(%{
        data_source_id: data_source.id,
        name: "some name",
        symbol: "SOME#{System.unique_integer([:positive])}"
      })
      |> Map.delete(:data_source)
      |> WorldTracker.Markets.create_ticker()

    ticker
  end

  @doc """
  Generate a ticker_price.
  """
  def ticker_price_fixture(attrs \\ %{}) do
    ticker = Map.get(attrs, :ticker) || ticker_fixture()

    {:ok, ticker_price} =
      attrs
      |> Enum.into(%{
        fetched_at: ~U[2026-03-22 09:33:00Z],
        price: "120.5",
        ticker_id: ticker.id
      })
      |> Map.delete(:ticker)
      |> WorldTracker.Markets.create_ticker_price()

    ticker_price
  end
end
