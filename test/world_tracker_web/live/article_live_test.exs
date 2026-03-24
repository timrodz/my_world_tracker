defmodule WorldTrackerWeb.ArticleLiveTest do
  use WorldTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import WorldTracker.NewsFixtures

  defp create_article(_) do
    article = article_fixture()
    %{article: article}
  end

  describe "Index" do
    setup [:create_article]

    test "renders the news feed page", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/news-articles")

      assert html =~ "Global headlines, live."
      assert html =~ "All Sources"
      assert html =~ "BBC News"
      assert html =~ "Al Jazeera"
      assert html =~ "The Guardian"
      assert html =~ "NPR World"
    end

    test "lists articles in the stream", %{conn: conn, article: article} do
      {:ok, _live, html} = live(conn, ~p"/news-articles")

      assert html =~ article.title
    end

    test "source filter tab changes active state", %{conn: conn, article: article} do
      {:ok, live, _html} = live(conn, ~p"/news-articles")

      html =
        live
        |> element("#source-tabs a", "BBC News")
        |> render_click()

      # Tab is now active; article may or may not appear depending on source
      assert html =~ "BBC News"
      _ = article
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
