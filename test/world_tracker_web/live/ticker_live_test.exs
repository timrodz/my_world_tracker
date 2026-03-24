defmodule WorldTrackerWeb.TickerLiveTest do
  use WorldTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import WorldTracker.MarketsFixtures
  import WorldTracker.NewsFixtures
  import WorldTracker.SourcesFixtures

  @invalid_attrs %{name: nil, symbol: nil, data_source_id: nil}

  defp create_ticker(_) do
    data_source = data_source_fixture()
    ticker = ticker_fixture(%{data_source: data_source})

    %{ticker: ticker, data_source: data_source}
  end

  describe "Index" do
    setup [:create_ticker]

    test "lists all tickers", %{conn: conn, ticker: ticker} do
      {:ok, _index_live, html} = live(conn, ~p"/tickers")

      assert html =~ "Listing Tickers"
      assert html =~ ticker.symbol
    end

    test "saves new ticker", %{conn: conn} do
      data_source = data_source_fixture()
      create_attrs = %{name: "some name", symbol: "some symbol", data_source_id: data_source.id}

      {:ok, index_live, _html} = live(conn, ~p"/tickers")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Ticker")
               |> render_click()
               |> follow_redirect(conn, ~p"/tickers/new")

      assert render(form_live) =~ "New Ticker"

      assert form_live
             |> form("#ticker-form", ticker: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#ticker-form", ticker: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tickers")

      html = render(index_live)
      assert html =~ "Ticker created successfully"
      assert html =~ "some symbol"
    end

    test "new ticker form only lists market data sources", %{conn: conn} do
      market_source = data_source_fixture(%{name: "Yahoo Finance", type: :markets})
      news_source = news_data_source_fixture(%{name: "BBC News"})

      {:ok, index_live, _html} = live(conn, ~p"/tickers")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Ticker")
               |> render_click()
               |> follow_redirect(conn, ~p"/tickers/new")

      html = render(form_live)
      assert html =~ market_source.name
      refute html =~ news_source.name
    end

    test "updates ticker in listing", %{conn: conn, ticker: ticker} do
      replacement_source = data_source_fixture()

      update_attrs = %{
        name: "some updated name",
        symbol: "some updated symbol",
        data_source_id: replacement_source.id
      }

      {:ok, index_live, _html} = live(conn, ~p"/tickers")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#tickers-#{ticker.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tickers/#{ticker}/edit")

      assert render(form_live) =~ "Edit Ticker"

      assert form_live
             |> form("#ticker-form", ticker: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#ticker-form", ticker: update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tickers")

      html = render(index_live)
      assert html =~ "Ticker updated successfully"
      assert html =~ "some updated symbol"
      assert html =~ replacement_source.name
    end

    test "edit ticker form only lists market data sources", %{conn: conn, ticker: ticker} do
      market_source = data_source_fixture(%{name: "Market Source", type: :markets})
      news_source = news_data_source_fixture(%{name: "News Source"})

      {:ok, index_live, _html} = live(conn, ~p"/tickers")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#tickers-#{ticker.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tickers/#{ticker}/edit")

      html = render(form_live)
      assert html =~ market_source.name
      refute html =~ news_source.name
    end

    test "deletes ticker in listing", %{conn: conn, ticker: ticker} do
      {:ok, index_live, _html} = live(conn, ~p"/tickers")

      assert index_live |> element("#tickers-#{ticker.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tickers-#{ticker.id}")
    end
  end

  describe "Show" do
    setup [:create_ticker]

    test "displays ticker", %{conn: conn, ticker: ticker} do
      {:ok, _show_live, html} = live(conn, ~p"/tickers/#{ticker}")

      assert html =~ ticker.name
      assert html =~ ticker.symbol
    end

    test "formats stored prices with market price component", %{conn: conn, ticker: ticker} do
      ticker_price_fixture(%{
        ticker: ticker,
        price: "120.5",
        fetched_at: ~U[2026-03-23 09:33:00Z]
      })

      {:ok, _show_live, html} = live(conn, ~p"/tickers/#{ticker}")

      assert html =~ "$120.50"
    end

    test "updates ticker and returns to show", %{conn: conn, ticker: ticker} do
      replacement_source = data_source_fixture()

      update_attrs = %{
        name: "some updated name",
        symbol: "some updated symbol",
        data_source_id: replacement_source.id
      }

      {:ok, show_live, _html} = live(conn, ~p"/tickers/#{ticker}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tickers/#{ticker}/edit?return_to=show")

      assert render(form_live) =~ "Edit Ticker"

      assert form_live
             |> form("#ticker-form", ticker: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#ticker-form", ticker: update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tickers/#{ticker}")

      html = render(show_live)
      assert html =~ "Ticker updated successfully"
      assert html =~ "some updated symbol"
    end
  end
end
