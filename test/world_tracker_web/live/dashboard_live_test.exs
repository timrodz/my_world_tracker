defmodule WorldTrackerWeb.DashboardLiveTest do
  use WorldTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import WorldTracker.MarketsFixtures

  test "renders latest ticker prices without crashing", %{conn: conn} do
    commodity = ticker_fixture(%{name: "Crude Oil", symbol: "CL=F"})
    currency = ticker_fixture(%{name: "EUR/USD", symbol: "EURUSD=X"})
    index = ticker_fixture(%{name: "S&P 500", symbol: "^GSPC"})

    ticker_price_fixture(%{
      ticker: commodity,
      price: "99.1",
      fetched_at: ~U[2026-03-23 09:56:52Z]
    })

    ticker_price_fixture(%{
      ticker: currency,
      price: "1.0824",
      fetched_at: ~U[2026-03-23 09:56:52Z]
    })

    ticker_price_fixture(%{
      ticker: index,
      price: "5842.1",
      fetched_at: ~U[2026-03-23 09:56:52Z]
    })

    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "Crude Oil"
    assert html =~ "$99.10"
    assert html =~ "$1.08"
    assert html =~ "$5842.10"
    assert html =~ "2026-03-23 09:56 UTC"
    refute html =~ "Awaiting first poll"
  end
end
