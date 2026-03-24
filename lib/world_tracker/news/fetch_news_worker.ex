defmodule WorldTracker.News.FetchNewsWorker do
  use Oban.Worker, queue: :news, max_attempts: 3

  require Logger

  alias Oban.Job
  alias Phoenix.PubSub
  alias WorldTracker.News
  alias WorldTracker.News.RssFetcher
  alias WorldTracker.Sources

  def enqueue(attrs \\ %{})

  def enqueue(attrs) when is_map(attrs) do
    Logger.debug("enqueueing news fetch job attrs=#{inspect(attrs)}")

    attrs
    |> new()
    |> Oban.insert()
  end

  def enqueue(source_slug) when is_binary(source_slug) do
    enqueue(%{source_slug: source_slug})
  end

  @impl Oban.Worker
  def perform(%Job{id: job_id, args: %{"source_slug" => source_slug}}) do
    started_at = System.monotonic_time(:millisecond)

    Logger.debug("starting news fetch job_id=#{job_id} source=#{source_slug}")

    result = fetch_and_store(source_slug)

    duration_ms = System.monotonic_time(:millisecond) - started_at

    case result do
      {:ok, count} ->
        Logger.debug(
          "completed news fetch job_id=#{job_id} source=#{source_slug} inserted=#{count} duration_ms=#{duration_ms}"
        )

        :ok

      {:error, reason} ->
        Logger.error(
          "news fetch failed job_id=#{job_id} source=#{source_slug} reason=#{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  def perform(%Job{id: job_id, args: args}) do
    started_at = System.monotonic_time(:millisecond)

    Logger.debug("starting news fetch orchestrator job_id=#{job_id} args=#{inspect(args)}")

    result = enqueue_news_sources()

    duration_ms = System.monotonic_time(:millisecond) - started_at

    case result do
      {:ok, count} ->
        Logger.debug(
          "completed news fetch orchestrator job_id=#{job_id} enqueued=#{count} duration_ms=#{duration_ms}"
        )

        :ok

      {:error, reason} ->
        Logger.error("news fetch orchestrator failed job_id=#{job_id} reason=#{inspect(reason)}")

        {:error, reason}
    end
  end

  defp enqueue_news_sources do
    Sources.list_news_data_sources()
    |> Enum.reduce_while({:ok, 0}, fn data_source, {:ok, count} ->
      case enqueue(%{source_slug: data_source.slug}) do
        {:ok, _job} -> {:cont, {:ok, count + 1}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp fetch_and_store(source_slug) do
    data_source = Sources.get_news_data_source_by_slug(source_slug)

    if is_nil(data_source) do
      {:error, "news data source not found for slug=#{source_slug}"}
    else
      case rss_fetcher().fetch(data_source) do
        {:ok, articles} ->
          count = News.upsert_articles(articles)

          if count > 0 do
            Logger.debug("broadcasting news update source=#{source_slug} inserted=#{count}")

            PubSub.broadcast(
              WorldTracker.PubSub,
              News.topic(),
              {:news_updated, source_slug}
            )
          end

          {:ok, count}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp rss_fetcher do
    Application.get_env(:world_tracker, :news_rss_fetcher, RssFetcher)
  end
end
