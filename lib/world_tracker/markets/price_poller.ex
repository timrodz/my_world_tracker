defmodule WorldTracker.Markets.PricePoller do
  use GenServer

  require Logger

  alias Phoenix.PubSub
  alias WorldTracker.Markets
  alias WorldTracker.Markets.YahooFinance

  @topic "ticker_prices"
  @default_interval :timer.seconds(60)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def topic, do: @topic

  @impl true
  def init(opts) do
    interval = Keyword.get(opts, :interval, @default_interval)
    Process.send_after(self(), :poll, 0)
    {:ok, %{interval: interval}}
  end

  @impl true
  def handle_info(:poll, state) do
    poll_prices()
    Process.send_after(self(), :poll, state.interval)
    {:noreply, state}
  end

  defp poll_prices do
    Markets.list_tickers_grouped_by_source()
    |> Enum.each(fn {slug, tickers} -> dispatch_source(slug, tickers) end)
  rescue
    error -> Logger.error("price polling failed: #{Exception.message(error)}")
  end

  defp dispatch_source("yahoo_finance", tickers) do
    tickers_by_symbol = Map.new(tickers, &{&1.symbol, &1})

    quotes = YahooFinance.fetch_quotes(tickers)

    latest_prices =
      quotes
      |> Enum.reduce([], fn quote, acc ->
        case Map.fetch(tickers_by_symbol, quote.symbol) do
          {:ok, ticker} when not is_nil(quote.price) ->
            case Markets.record_price(ticker, %{price: quote.price, fetched_at: quote.fetched_at}) do
              {:ok, ticker_price} ->
                [%{ticker: ticker, ticker_price: ticker_price} | acc]

              {:error, changeset} ->
                Logger.error(
                  "failed storing price for #{ticker.symbol}: #{inspect(changeset.errors)}"
                )

                acc
            end

          _ ->
            acc
        end
      end)
      |> Enum.reverse()

    if latest_prices != [] do
      PubSub.broadcast(WorldTracker.PubSub, @topic, {:prices_updated, Markets.latest_prices()})
    end
  end

  defp dispatch_source(slug, _tickers) do
    Logger.warning("no fetcher configured for source #{slug}")
  end
end
