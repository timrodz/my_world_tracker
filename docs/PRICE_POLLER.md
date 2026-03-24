# Price Poller

`WorldTracker.Markets.PricePoller` runs market price ingestion as an Oban background job instead of a long-lived `GenServer`.

## Architecture

- The worker lives at `lib/world_tracker/markets/price_poller.ex` and uses `Oban.Worker` on the `:market_prices` queue.
- Oban is configured in `config/config.exs` with a dedicated queue: `market_prices: 1`.
- The queue is scheduled by `Oban.Plugins.Cron` with `"* * * * *"`, so one polling job is enqueued every minute.
- `perform/1` loads tickers with `WorldTracker.Markets.list_tickers_grouped_by_source/0`, dispatches each source, fetches quotes, and stores prices through `WorldTracker.Markets.record_price/2`.
- The fetcher module is resolved through `:market_quote_fetchers`, which currently maps `"yahoo_finance"` to `WorldTracker.Markets.YahooFinance`.

## UI updates

- After at least one price is stored, the worker broadcasts `{:prices_updated, Markets.latest_prices()}` on the `"ticker_prices"` topic.
- `WorldTrackerWeb.DashboardLive` subscribes to `PricePoller.topic/0` and refreshes assigns in `handle_info/2`.
- This means background execution still updates the dashboard without any direct browser polling.

## Running it

Start the app normally:

```bash
iex -S mix phx.server
```

With the server running, Oban will:

- start the `:market_prices` queue
- enqueue a polling job every minute
- execute the worker in the background
- broadcast updates to connected LiveViews when prices change

To trigger a poll immediately from `iex`:

```elixir
WorldTracker.Markets.PricePoller.enqueue()
```

## Debug logs

Development logging is set to `:debug` in `config/dev.exs`, so you can watch the queue work in real time.

Useful log lines include:

- `enqueueing price polling job attrs=...`
- `starting price polling job_id=... queue=market_prices ...`
- `polling source=yahoo_finance ticker_count=...`
- `broadcasting price updates source=yahoo_finance stored=...`
- `completed price polling job_id=... queue=market_prices sources=... quotes=... stored=... broadcasts=... duration_ms=...`

## Configuration notes

- Queue config: `config/config.exs`
- Worker implementation: `lib/world_tracker/markets/price_poller.ex`
- Dashboard subscriber: `lib/world_tracker_web/live/dashboard_live.ex`
- Test mode disables automatic Oban execution in `config/test.exs`, so worker tests can control job execution manually.

## Troubleshooting

- If jobs are not running, confirm the app booted with Oban and that the `:market_prices` queue is configured.
- If the dashboard does not update, check for the `broadcasting price updates` debug line and verify there are active LiveView subscribers.
- If no prices are stored, inspect source-specific logs and any `failed storing price` errors.
