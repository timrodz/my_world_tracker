defmodule WorldTrackerWeb.TickerLive.Show do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Markets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@ticker.name}
        <:subtitle>
          The symbol, source, and recent price snapshots for this tracked instrument.
        </:subtitle>
        <:actions>
          <.button link_type="a" to={~p"/tickers"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            link_type="live_patch"
            color="primary"
            to={~p"/tickers/#{@ticker}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit Ticker
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Source">{@ticker.data_source.name}</:item>
        <:item title="Symbol">{@ticker.symbol}</:item>
        <:item title="Name">{@ticker.name}</:item>
      </.list>

      <section class="mt-8 rounded-3xl border border-base-300 bg-base-100 p-6 shadow-sm">
        <div class="mb-4 flex items-center justify-between gap-4">
          <div>
            <h2 class="text-lg font-semibold text-base-content">Recent Snapshots</h2>
            <p class="text-sm text-base-content/65">Latest stored prices for this ticker.</p>
          </div>
        </div>

        <div
          :if={@ticker.ticker_prices == []}
          class="rounded-2xl border border-dashed border-base-300 px-4 py-6 text-sm text-base-content/65"
        >
          No prices have been collected yet.
        </div>

        <div
          :if={@ticker.ticker_prices != []}
          class="overflow-hidden rounded-2xl border border-base-300"
        >
          <table class="min-w-full divide-y divide-base-300 text-sm">
            <thead class="bg-base-200/60">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-base-content/70">
                  Fetched At
                </th>
                <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide text-base-content/70">
                  Price
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-base-300 bg-base-100">
              <tr
                :for={ticker_price <- @ticker.ticker_prices}
                class="hover:bg-base-200/50 transition-colors"
              >
                <td class="px-4 py-3 text-base-content">
                  {Calendar.strftime(ticker_price.fetched_at, "%Y-%m-%d %H:%M:%S UTC")}
                </td>
                <td class="px-4 py-3 text-right font-semibold text-base-content">
                  <.market_price price={ticker_price.price} currency_symbol="$" decimals={2} />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Ticker")
     |> assign(:ticker, Markets.get_ticker!(id))}
  end
end
