defmodule WorldTrackerWeb.ArticleLiveTest do
  use WorldTrackerWeb.ConnCase
  use Oban.Testing, repo: WorldTracker.Repo

  import Phoenix.LiveViewTest
  import WorldTracker.NewsFixtures

  alias WorldTracker.News.FetchNewsWorker

  defp create_article(_) do
    article = article_fixture()
    %{article: article}
  end

  describe "Index" do
    setup [:create_article]

    test "renders the news feed page", %{conn: conn} do
      first = news_data_source_fixture(%{name: "BBC News"})
      second = news_data_source_fixture(%{name: "Al Jazeera"})

      {:ok, _live, html} = live(conn, ~p"/news-articles")

      assert html =~ "Global headlines, live."
      assert html =~ "All Sources"
      assert html =~ first.name
      assert html =~ second.name
      assert html =~ "Refresh all sources"
    end

    test "lists articles in the stream", %{conn: conn, article: article} do
      {:ok, _live, html} = live(conn, ~p"/news-articles")

      assert html =~ article.title
    end

    test "source filter tab changes active state", %{conn: conn, article: article} do
      source = article.data_source

      {:ok, live, _html} = live(conn, ~p"/news-articles")

      html =
        live
        |> element("#source-tabs a", source.name)
        |> render_click()

      # Tab is now active; article may or may not appear depending on source
      assert html =~ source.name
      assert html =~ article.title
    end

    test "manual refresh buttons queue jobs", %{conn: conn} do
      source = news_data_source_fixture(%{name: "BBC News"})

      {:ok, live, _html} = live(conn, ~p"/news-articles")

      live
      |> element("#fetch-all-news")
      |> render_click()

      assert_enqueued(worker: FetchNewsWorker, queue: :news, args: %{})

      live
      |> element("#fetch-source-#{source.slug}")
      |> render_click()

      assert_enqueued(
        worker: FetchNewsWorker,
        queue: :news,
        args: %{"source_slug" => source.slug}
      )
    end
  end

  describe "Show" do
    setup [:create_article]

    test "displays article", %{conn: conn, article: article} do
      {:ok, _show_live, html} = live(conn, ~p"/news-articles/#{article}")

      assert html =~ "Show Article"
      assert html =~ article.guid
    end
  end
end
