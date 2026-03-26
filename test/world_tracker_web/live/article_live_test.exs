defmodule WorldTrackerWeb.ArticleLiveTest do
  use WorldTrackerWeb.ConnCase
  use Oban.Testing, repo: WorldTracker.Repo

  import Phoenix.LiveViewTest
  import WorldTracker.NewsFixtures

  alias WorldTracker.Workers.NewsFeeds

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

      assert_enqueued(worker: NewsFeeds, queue: :news, args: %{})

      live
      |> element("#fetch-source-#{source.slug}")
      |> render_click()

      assert_enqueued(
        worker: NewsFeeds,
        queue: :news,
        args: %{"source_slug" => source.slug}
      )
    end

    test "shows pagination controls when multiple pages exist", %{conn: conn} do
      source = news_data_source_fixture(%{name: "BBC News"})

      # Create 8 articles to ensure we have multiple pages (6 per page)
      for i <- 1..8 do
        article_fixture(%{
          title: "Article #{i}",
          data_source_id: source.id,
          guid: "guid-#{i}"
        })
      end

      {:ok, _live, html} = live(conn, ~p"/news-articles?source=#{source.slug}")

      # Should show pagination controls
      assert html =~ "Showing"
      assert html =~ "of"
      assert html =~ "results"
    end

    test "does not show pagination controls when only one page", %{conn: conn} do
      # Create only 3 articles (less than 6 per page)
      for i <- 1..3 do
        article_fixture(%{
          title: "Single Page Article #{i}",
          guid: "single-page-guid-#{i}"
        })
      end

      {:ok, _live, html} = live(conn, ~p"/news-articles")

      # Should not show pagination controls
      refute html =~ "Showing"
      refute html =~ "of"
      refute html =~ "results"
    end

    test "pagination navigation works correctly", %{conn: conn} do
      source = news_data_source_fixture(%{name: "Test Source"})

      # Create 10 articles to have 2 pages
      for i <- 1..10 do
        article_fixture(%{
          title: "Test Article #{i}",
          data_source_id: source.id,
          guid: "test-guid-#{i}"
        })
      end

      {:ok, live, _html} = live(conn, ~p"/news-articles?source=#{source.slug}")

      # Click next page button using the desktop version (with chevron icon)
      html =
        live
        |> element("nav[aria-label='Pagination'] a:last-child")
        |> render_click()

      # Should show page 2 content
      assert html =~ "Showing"
      assert html =~ "of"

      # Click previous page button (desktop version)
      html =
        live
        |> element("nav[aria-label='Pagination'] a:first-child")
        |> render_click()

      # Should be back on page 1
      assert html =~ "Showing"
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
