defmodule WorldTracker.Markets.YahooFinanceStub do
  @moduledoc false

  def fetch_quotes(tickers) do
    Enum.map(tickers, fn ticker ->
      %{
        symbol: ticker.symbol,
        price: Decimal.new(price_for_symbol(ticker.symbol)),
        fetched_at: ~U[2026-03-24 12:00:00Z]
      }
    end)
  end

  defp price_for_symbol(symbol) do
    if String.starts_with?(symbol, "TEST") do
      "123.45"
    else
      "101.01"
    end
  end
end
