defmodule WorldTracker.News.FetchNewsWorker do
  use Oban.Worker, queue: :news, max_attempts: 3

  require Logger

  import Ecto.Query, warn: false

  alias Oban.Job
  alias Phoenix.PubSub
  alias WorldTracker.News
  alias WorldTracker.News.RssFetcher
  alias WorldTracker.Repo
  alias WorldTracker.Sources.DataSource

  @valid_slugs ~w(bbc_news al_jazeera the_guardian npr_world)

  def enqueue(source_slug) when source_slug in @valid_slugs do
    Logger.debug("enqueueing news fetch job source_slug=#{source_slug}")

    %{source_slug: source_slug}
    |> new()
    |> Oban.insert()
  end

  def enqueue(source_slug) do
    {:error,
     "unknown source slug #{inspect(source_slug)}, valid slugs: #{Enum.join(@valid_slugs, ", ")}"}
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

  defp fetch_and_store(source_slug) do
    data_source =
      Repo.one(from(ds in DataSource, where: ds.slug == ^source_slug and ds.type == :news))

    if is_nil(data_source) do
      {:error, "news data source not found for slug=#{source_slug}"}
    else
      case RssFetcher.fetch(data_source) do
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
end
