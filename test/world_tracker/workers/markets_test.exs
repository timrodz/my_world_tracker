defmodule WorldTracker.Markets.PricePollerTest do
  use WorldTracker.DataCase, async: false
  use Oban.Testing, repo: WorldTracker.Repo

  import WorldTracker.MarketsFixtures
  import WorldTracker.SourcesFixtures

  alias WorldTracker.Markets
  alias WorldTracker.Workers
  alias WorldTracker.Sources

  setup do
    original_fetchers = Application.get_env(:world_tracker, :market_quote_fetchers)

    Application.put_env(
      :world_tracker,
      :market_quote_fetchers,
      %{"yahoo_finance" => WorldTracker.Markets.YahooFinanceStub}
    )

    on_exit(fn ->
      case original_fetchers do
        nil -> Application.delete_env(:world_tracker, :market_quote_fetchers)
        fetchers -> Application.put_env(:world_tracker, :market_quote_fetchers, fetchers)
      end
    end)

    :ok
  end

  test "enqueue/1 schedules the worker on the market_prices queue" do
    assert {:ok, _job} = Workers.Markets.enqueue()
    assert_enqueued(worker: Workers.Markets, queue: :market_prices)
  end

  test "perform/1 records prices and broadcasts updates to subscribers" do
    data_source =
      Enum.find(Sources.list_data_sources(), &(&1.slug == "yahoo_finance")) ||
        data_source_fixture(%{name: "Yahoo Finance", slug: "yahoo_finance"})

    symbol = "TEST#{System.unique_integer([:positive])}"
    ticker = ticker_fixture(%{data_source: data_source, name: "Gold", symbol: symbol})

    Phoenix.PubSub.subscribe(WorldTracker.PubSub, Workers.Markets.topic())

    assert :ok = perform_job(Workers.Markets, %{})

    latest_price =
      Enum.find(Markets.latest_prices(), fn price ->
        price.ticker_id == ticker.id and price.symbol == ticker.symbol
      end)

    assert latest_price
    assert latest_price.price == Decimal.new("123.45")
    assert latest_price.fetched_at == ~U[2026-03-24 12:00:00Z]

    assert_receive {:prices_updated, prices}

    assert Enum.any?(prices, fn price ->
             price.ticker_id == ticker.id and price.symbol == ticker.symbol and
               price.price == Decimal.new("123.45")
           end)
  end
end
