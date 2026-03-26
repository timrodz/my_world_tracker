defmodule WorldTracker.Workers.Markets do
  use Oban.Worker, queue: :market_prices, max_attempts: 1

  require Logger

  alias Oban.Job
  alias Phoenix.PubSub
  alias WorldTracker.Markets
  alias WorldTracker.Markets.YahooFinance

  @topic "ticker_prices"

  def topic, do: @topic

  def enqueue(attrs \\ %{}) do
    Logger.debug("enqueueing price polling job attrs=#{inspect(attrs)}")

    attrs
    |> new()
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Job{id: job_id, queue: queue, args: args}) do
    started_at = System.monotonic_time(:millisecond)

    Logger.debug("starting price polling job_id=#{job_id} queue=#{queue} args=#{inspect(args)}")

    stats = poll_prices()

    duration_ms = System.monotonic_time(:millisecond) - started_at

    Logger.debug(
      "completed price polling job_id=#{job_id} queue=#{queue} sources=#{stats.sources} quotes=#{stats.quotes} stored=#{stats.stored} broadcasts=#{stats.broadcasts} duration_ms=#{duration_ms}"
    )

    :ok
  rescue
    error ->
      Logger.error("price polling failed job_id=#{job_id}: #{Exception.message(error)}")
      :ok
  end

  defp poll_prices do
    Markets.list_tickers_grouped_by_source()
    |> Enum.reduce(%{sources: 0, quotes: 0, stored: 0, broadcasts: 0}, fn {slug, tickers}, acc ->
      stats = dispatch_source(slug, tickers)

      %{
        sources: acc.sources + 1,
        quotes: acc.quotes + stats.quotes,
        stored: acc.stored + stats.stored,
        broadcasts: acc.broadcasts + stats.broadcasts
      }
    end)
  end

  defp dispatch_source("yahoo_finance", tickers) do
    Logger.debug("polling source=yahoo_finance ticker_count=#{length(tickers)}")

    tickers_by_symbol = Map.new(tickers, &{&1.symbol, &1})

    quotes = quote_fetcher("yahoo_finance").fetch_quotes(tickers)

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
      Logger.debug(
        "broadcasting price updates source=yahoo_finance stored=#{length(latest_prices)}"
      )

      PubSub.broadcast(WorldTracker.PubSub, @topic, {:prices_updated, Markets.latest_prices()})
    end

    Logger.debug(
      "finished source=yahoo_finance ticker_count=#{length(tickers)} quote_count=#{length(quotes)} stored=#{length(latest_prices)}"
    )

    %{
      quotes: length(quotes),
      stored: length(latest_prices),
      broadcasts: if(latest_prices == [], do: 0, else: 1)
    }
  end

  defp dispatch_source(slug, _tickers) do
    Logger.warning("no fetcher configured for source #{slug}")
    %{quotes: 0, stored: 0, broadcasts: 0}
  end

  defp quote_fetcher(slug) do
    fetchers = Application.get_env(:world_tracker, :market_quote_fetchers, %{})

    case Map.fetch(fetchers, slug) do
      {:ok, fetcher} -> fetcher
      :error -> default_quote_fetcher(slug)
    end
  end

  defp default_quote_fetcher("yahoo_finance"), do: YahooFinance
end
