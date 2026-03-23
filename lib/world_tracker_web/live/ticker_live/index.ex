defmodule WorldTrackerWeb.TickerLive.Index do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Markets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Tickers
        <:actions>
          <.button variant="primary" navigate={~p"/tickers/new"}>
            <.icon name="hero-plus" /> New Ticker
          </.button>
        </:actions>
      </.header>

      <.table
        id="tickers"
        rows={@streams.tickers}
        row_click={fn {_id, ticker} -> JS.navigate(~p"/tickers/#{ticker}") end}
      >
        <:col :let={{_id, ticker}} label="Source">{ticker.data_source.name}</:col>
        <:col :let={{_id, ticker}} label="Symbol">{ticker.symbol}</:col>
        <:col :let={{_id, ticker}} label="Name">{ticker.name}</:col>
        <:action :let={{_id, ticker}}>
          <div class="sr-only">
            <.link navigate={~p"/tickers/#{ticker}"}>Show</.link>
          </div>
          <.link navigate={~p"/tickers/#{ticker}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, ticker}}>
          <.link
            phx-click={JS.push("delete", value: %{id: ticker.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Tickers")
     |> stream(:tickers, list_tickers())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ticker = Markets.get_ticker!(id)
    {:ok, _} = Markets.delete_ticker(ticker)

    {:noreply, stream_delete(socket, :tickers, ticker)}
  end

  defp list_tickers() do
    Markets.list_tickers()
  end
end
