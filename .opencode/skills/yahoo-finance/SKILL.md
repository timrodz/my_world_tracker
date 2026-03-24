---
name: yahoo-finance
description: Work with Yahoo Finance polling, Oban queues, price persistence, and LiveView frontend updates in WorldTracker
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: phoenix
---

## What I do

- Implement or update Yahoo Finance-backed market polling in `WorldTracker`
- Keep polling work in Oban queues instead of long-lived processes
- Preserve LiveView updates through PubSub broadcasts after prices are stored
- Add debug logging, tests, and docs for the polling flow

## Current architecture

- Worker: `lib/world_tracker/markets/price_poller.ex`
- Queue: `:market_prices`
- Scheduler: `Oban.Plugins.Cron` in `config/config.exs` with `"* * * * *"`
- Source lookup: `Application.get_env(:world_tracker, :market_quote_fetchers, %{})`
- Default fetcher: `WorldTracker.Markets.YahooFinance`
- Persistence: `WorldTracker.Markets.record_price/2`
- Frontend update path: `Phoenix.PubSub.broadcast(WorldTracker.PubSub, PricePoller.topic(), {:prices_updated, Markets.latest_prices()})`
- Subscriber: `lib/world_tracker_web/live/dashboard_live.ex`

## How to work on it

- Use `Oban.Worker`, not `GenServer`, for recurring polling jobs
- Put queue definitions in `config/config.exs`; only configured queues run jobs
- Keep the polling queue concurrency low, currently `market_prices: 1`, to avoid overlapping runs
- Schedule recurring execution with `Oban.Plugins.Cron`
- Preserve `PricePoller.topic/0` so LiveViews can keep subscribing without extra changes
- Broadcast only after successful inserts so the frontend refreshes from persisted data
- Inject fetcher modules through `:market_quote_fetchers` so tests can replace Yahoo calls with stubs

## Logging expectations

In development, logging is set to `:debug` in `config/dev.exs`.

Useful log lines:

- `enqueueing price polling job attrs=...`
- `starting price polling job_id=... queue=market_prices ...`
- `polling source=yahoo_finance ticker_count=...`
- `broadcasting price updates source=yahoo_finance stored=...`
- `completed price polling job_id=... queue=market_prices sources=... quotes=... stored=... broadcasts=... duration_ms=...`
- `failed storing price for ...`

## Testing pattern

- In `config/test.exs`, keep Oban in manual mode with plugins and queues disabled
- Use `Oban.Testing` for `assert_enqueued/1` and `perform_job/2`
- Stub Yahoo fetches with a test module, e.g. `test/support/stubs/yahoo_finance_stub.ex`
- Verify three outcomes: job enqueued, prices persisted, PubSub broadcast received

## Common tasks

### Trigger a poll manually

```elixir
WorldTracker.Markets.PricePoller.enqueue()
```

### Run the app and watch polling

```bash
iex -S mix phx.server
```

### Run the worker test

```bash
mix test test/world_tracker/markets/price_poller_test.exs
```

### Run full checks

```bash
mix precommit
```

## Files to update together

- `lib/world_tracker/markets/price_poller.ex`
- `config/config.exs`
- `config/test.exs`
- `config/dev.exs`
- `lib/world_tracker/application.ex`
- `lib/world_tracker_web/live/dashboard_live.ex`
- `test/world_tracker/markets/price_poller_test.exs`
- `test/support/stubs/yahoo_finance_stub.ex`
- `docs/PRICE_POLLER.md`

## When to use me

Use this when you need to change Yahoo Finance polling, queue scheduling, background execution, persisted market prices, or frontend price refresh behavior.
