# News Fetch Worker

`WorldTracker.Workers.NewsFeeds` runs RSS news ingestion as an Oban background job.

## Architecture

- The worker lives at `lib/world_tracker/news/fetch_news_worker.ex` and uses `Oban.Worker` on the `:news` queue.
- Oban is configured in `config/config.exs` with a dedicated queue: `news: 4`.
- The queue is scheduled by `Oban.Plugins.Cron` with `"*/15 * * * *"`, so one job per source is enqueued every 15 minutes.
- `perform/1` looks up the `DataSource` record by slug and type `:news`, calls `WorldTracker.News.RssFetcher.fetch/1`, and upserts articles through `WorldTracker.News.upsert_articles/1`.
- Articles are deduplicated on `(data_source_id, guid)` — re-fetching the same feed never creates duplicates.

## Sources

| Slug           | Name         | Feed                                          |
| -------------- | ------------ | --------------------------------------------- |
| `bbc_news`     | BBC News     | `https://feeds.bbci.co.uk/news/world/rss.xml` |
| `al_jazeera`   | Al Jazeera   | `https://www.aljazeera.com/xml/rss/all.xml`   |
| `the_guardian` | The Guardian | `https://www.theguardian.com/world/rss`       |
| `npr_world`    | NPR World    | `https://feeds.npr.org/1004/rss.xml`          |

## UI updates

- After articles are upserted, the worker broadcasts `{:news_updated, source_slug}` on the `"news_articles"` topic.
- `WorldTrackerWeb.ArticleLive.Index` and `WorldTrackerWeb.DashboardLive` both subscribe to `News.topic/0` and reset their streams in `handle_info/2`.
- This means background execution updates all connected LiveViews without any direct browser polling.

## Running it

Start the app normally:

```bash
iex -S mix phx.server
```

With the server running, Oban will:

- start the `:news` queue with concurrency 4
- enqueue one job per source every 15 minutes
- execute each worker in the background
- broadcast updates to connected LiveViews when new articles are inserted

To enqueue a fetch immediately from `iex`:

```elixir
WorldTracker.Workers.NewsFeeds.enqueue("bbc_news")
WorldTracker.Workers.NewsFeeds.enqueue("al_jazeera")
WorldTracker.Workers.NewsFeeds.enqueue("the_guardian")
WorldTracker.Workers.NewsFeeds.enqueue("npr_world")
```

To enqueue a fetch from the command line (app does not need to be running):

```bash
mix news.fetch bbc_news
mix news.fetch al_jazeera
mix news.fetch the_guardian
mix news.fetch npr_world
```

## Debug logs

Development logging is set to `:debug` in `config/dev.exs`, so you can watch the queue work in real time.

Useful log lines include:

- `enqueueing news fetch job source_slug=...`
- `starting news fetch job_id=... source=...`
- `broadcasting news update source=... inserted=...`
- `completed news fetch job_id=... source=... inserted=... duration_ms=...`

## Configuration notes

- Queue config: `config/config.exs`
- Worker implementation: `lib/world_tracker/news/fetch_news_worker.ex`
- RSS fetcher: `lib/world_tracker/news/rss_fetcher.ex`
- News context: `lib/world_tracker/news.ex`
- Mix task: `lib/mix/tasks/news.fetch.ex`
- LiveView subscribers: `lib/world_tracker_web/live/article_live/index.ex`, `lib/world_tracker_web/live/dashboard_live.ex`
- Test mode disables automatic Oban execution in `config/test.exs`, so worker tests can control job execution manually.

## Troubleshooting

- If jobs are not running, confirm the app booted with Oban and that the `:news` queue is configured.
- If the dashboard or news feed does not update, check for the `broadcasting news update` debug line and verify there are active LiveView subscribers.
- If no articles are stored, inspect the `RssFetcher` logs for HTTP or parse errors and confirm the data source record exists with `type = :news` and a valid `endpoint_url`.
- If `mix news.fetch` reports `unknown source slug`, ensure the slug matches one of the four valid values listed above.
