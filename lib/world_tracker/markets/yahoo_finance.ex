defmodule WorldTracker.Markets.YahooFinance do
  @moduledoc false

  @fields ~w[currentPrice regularMarketPrice previousClose lastPrice]

  def fetch_quotes(tickers) when is_list(tickers) do
    symbols =
      tickers
      |> Enum.map(& &1.symbol)
      |> IO.inspect(label: "Symbols to fetch from Yahoo Finance")

    {result, _globals} =
      Pythonx.eval(
        """
        import yfinance as yf

        rows = []

        for bytes_symbol in symbols:
            symbol = bytes_symbol.decode("utf-8")
            ticker = yf.Ticker(symbol)
            info = ticker.fast_info or {}

            price = None
            for field in fields:
                value = info.get(field)
                if value is not None:
                    price = value
                    break

            if price is None:
                history = ticker.history(period="1d", interval="1m")
                if not history.empty:
                    price = float(history["Close"].iloc[-1])

            previous_close = info.get("previousClose")
            market_time = info.get("lastPriceTimestamp")

            rows.append({
                "symbol": symbol,
                "price": None if price is None else str(price),
                "previous_close": None if previous_close is None else str(previous_close),
                "fetched_at": None if market_time is None else int(market_time),
            })

        rows
        """,
        %{"symbols" => symbols, "fields" => @fields}
      )

    result
    |> Pythonx.decode()
    |> Enum.map(&normalize_quote/1)
  end

  defp normalize_quote(%{"symbol" => symbol, "price" => nil}) do
    %{symbol: symbol, price: nil, fetched_at: DateTime.utc_now() |> DateTime.truncate(:second)}
  end

  defp normalize_quote(%{"symbol" => symbol, "price" => price, "fetched_at" => unix}) do
    fetched_at =
      case unix do
        value when is_integer(value) -> DateTime.from_unix!(value) |> DateTime.truncate(:second)
        _ -> DateTime.utc_now() |> DateTime.truncate(:second)
      end

    %{symbol: symbol, price: Decimal.new(price), fetched_at: fetched_at}
  end
end
