defmodule WorldTracker.News.FetchNewsWorkerTest do
  use WorldTracker.DataCase, async: false
  use Oban.Testing, repo: WorldTracker.Repo

  import WorldTracker.NewsFixtures

  alias WorldTracker.News
  alias WorldTracker.News.FetchNewsWorker

  setup do
    original_fetcher = Application.get_env(:world_tracker, :news_rss_fetcher)
    Application.put_env(:world_tracker, :news_rss_fetcher, WorldTracker.News.RssFetcherStub)

    on_exit(fn ->
      case original_fetcher do
        nil -> Application.delete_env(:world_tracker, :news_rss_fetcher)
        fetcher -> Application.put_env(:world_tracker, :news_rss_fetcher, fetcher)
      end
    end)

    :ok
  end

  test "enqueue/0 schedules the orchestrator job on the news queue" do
    assert {:ok, _job} = FetchNewsWorker.enqueue()
    assert_enqueued(worker: FetchNewsWorker, queue: :news)
  end

  test "perform/1 orchestrates one child job per news source" do
    first = news_data_source_fixture(%{name: "BBC News", slug: "bbc-news"})
    second = news_data_source_fixture(%{name: "NPR World", slug: "npr-world"})

    assert :ok = perform_job(FetchNewsWorker, %{})

    assert_enqueued(worker: FetchNewsWorker, queue: :news, args: %{"source_slug" => first.slug})
    assert_enqueued(worker: FetchNewsWorker, queue: :news, args: %{"source_slug" => second.slug})
  end

  test "perform/1 fetches, stores, and broadcasts for a single source" do
    source = news_data_source_fixture(%{name: "BBC News", slug: "bbc-news"})
    source_slug = source.slug

    Phoenix.PubSub.subscribe(WorldTracker.PubSub, News.topic())

    assert :ok = perform_job(FetchNewsWorker, %{source_slug: source.slug})

    articles = News.list_news_articles(source: source.slug)
    assert length(articles) == 1
    assert hd(articles).guid == "guid-#{source.slug}"

    assert_receive {:news_updated, ^source_slug}
  end

  test "perform/1 returns an error when the news source is missing" do
    assert {:error, "news data source not found for slug=missing-source"} =
             perform_job(FetchNewsWorker, %{source_slug: "missing-source"})
  end
end
