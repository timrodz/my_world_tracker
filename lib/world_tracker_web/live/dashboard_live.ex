defmodule WorldTrackerWeb.DashboardLive do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.Markets
  alias WorldTracker.Markets.PricePoller
  alias WorldTracker.News

  @groups [
    %{
      label: "Commodities",
      symbols: ["GC=F", "SI=F", "CL=F"],
      price_options: %{currency_symbol: "$", decimals: 2}
    },
    %{
      label: "Currencies",
      symbols: ["DX-Y.NYB", "EURUSD=X", "GBPUSD=X"],
      price_options: %{currency_symbol: "$", decimals: 2}
    },
    %{
      label: "Indices",
      symbols: ["^GSPC", "^DJI", "^RUT", "^N225"],
      price_options: %{currency_symbol: "$", decimals: 2}
    }
  ]

  @news_limit 6

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WorldTracker.PubSub, PricePoller.topic())
      Phoenix.PubSub.subscribe(WorldTracker.PubSub, News.topic())
    end

    prices = Markets.latest_prices()
    articles = News.list_news_articles(limit: @news_limit)

    {:ok,
     socket
     |> assign(:page_title, "Market Dashboard")
     |> assign(:groups, grouped_prices(prices))
     |> assign(:last_updated_at, last_updated_at(prices))
     |> stream(:news_articles, articles)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <%!-- Hero --%>
      <section class="relative overflow-hidden rounded-[2rem] border border-base-300 bg-[radial-gradient(circle_at_top_left,_rgba(251,191,36,0.22),_transparent_32%),linear-gradient(135deg,_rgba(15,23,42,0.98),_rgba(30,41,59,0.92))] px-6 py-10 text-base-100 shadow-2xl shadow-slate-950/15 sm:px-10">
        <div class="absolute inset-y-0 right-0 w-1/2 bg-[radial-gradient(circle_at_center,_rgba(56,189,248,0.14),_transparent_58%)]" />
        <div class="relative flex flex-col gap-8 lg:flex-row lg:items-end lg:justify-between">
          <div class="max-w-2xl space-y-4">
            <p class="text-xs font-semibold uppercase tracking-[0.35em] text-amber-300/80">
              World Tracker
            </p>
            <h1 class="font-serif text-4xl leading-tight text-white sm:text-5xl">
              Major money indicators in one live board.
            </h1>
            <p class="max-w-xl text-sm leading-7 text-slate-200/78 sm:text-base">
              Yahoo Finance-backed snapshots for commodities, currencies, and global indices, refreshed every minute and persisted for historical review.
            </p>
          </div>

          <div class="grid gap-3 rounded-[1.75rem] border border-white/10 bg-white/8 p-4 text-sm text-slate-100 backdrop-blur sm:grid-cols-2">
            <div>
              <p class="text-xs uppercase tracking-[0.24em] text-slate-300">Data Source</p>
              <p class="mt-2 text-lg font-semibold text-white">Yahoo Finance</p>
            </div>
            <div>
              <p class="text-xs uppercase tracking-[0.24em] text-slate-300">Last Refresh</p>
              <p class="mt-2 text-lg font-semibold text-white">
                {format_timestamp(@last_updated_at)}
              </p>
            </div>
          </div>
        </div>
      </section>

      <%!-- Market cards --%>
      <section class="grid gap-6 lg:grid-cols-3">
        <article
          :for={group <- @groups}
          class="overflow-hidden rounded-[2rem] border border-base-300 bg-base-100 shadow-sm"
        >
          <div class="border-b border-base-300 bg-base-200/80 px-5 py-4">
            <h2 class="text-lg font-semibold text-base-content">{group.label}</h2>
          </div>

          <div class="divide-y divide-base-300">
            <div :for={row <- group.rows} class="group px-5 py-4 transition hover:bg-base-200/70">
              <div class="flex items-start justify-between gap-4">
                <div>
                  <p class="font-semibold text-base-content">{row.name}</p>
                  <p class="mt-1 text-xs uppercase tracking-[0.22em] text-base-content/55">
                    {row.symbol}
                  </p>
                </div>
                <div class="text-right">
                  <.market_price
                    price={row.price}
                    currency_symbol={group.price_options[:currency_symbol]}
                    decimals={group.price_options[:decimals]}
                    class="text-xl font-semibold text-base-content"
                  />
                </div>
              </div>
            </div>

            <div :if={group.rows == []} class="px-5 py-10 text-sm text-base-content/55">
              No tracked instruments in this category yet.
            </div>
          </div>
        </article>
      </section>

      <%!-- Latest news --%>
      <section>
        <div class="mb-4 flex items-center justify-between">
          <h2 class="text-xl font-semibold text-base-content">Latest World News</h2>
          <.link navigate={~p"/news-articles"}>
            View all <.icon name="hero-arrow-right" class="inline-block w-3.5 h-3.5" />
          </.link>
        </div>

        <div id="dashboard-news" phx-update="stream" class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          <a
            :for={{dom_id, article} <- @streams.news_articles}
            id={dom_id}
            href={article.url}
            target="_blank"
            rel="noopener noreferrer"
            class="group flex gap-3 rounded-[1.25rem] border border-base-300 bg-base-100 p-4 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md"
          >
            <%!-- Thumbnail --%>
            <div
              :if={article.image_url}
              class="h-16 w-16 shrink-0 overflow-hidden rounded-xl bg-base-200"
            >
              <img
                src={article.image_url}
                alt=""
                class="h-full w-full object-cover"
                loading="lazy"
              />
            </div>

            <div class="flex min-w-0 flex-col gap-1">
              <div class="flex items-center gap-2">
                <span class="text-xs font-semibold uppercase tracking-wide text-base-content/50">
                  {article.data_source.name}
                </span>
                <span :if={article.published_at} class="text-xs text-base-content/35 tabular-nums">
                  {format_date(article.published_at)}
                </span>
              </div>
              <p class="line-clamp-2 text-sm font-medium leading-snug text-base-content transition-colors group-hover:text-primary">
                {article.title}
              </p>
            </div>
          </a>
        </div>
      </section>

      <%!-- Nav links --%>
      <section class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <.link
          navigate={~p"/data-sources"}
          class="rounded-[1.5rem] border border-base-300 bg-base-100 px-5 py-4 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md"
        >
          <p class="text-xs font-semibold uppercase tracking-[0.24em] text-base-content/45">Manage</p>
          <p class="mt-2 text-lg font-semibold text-base-content">Data Sources</p>
          <p class="mt-1 text-sm text-base-content/65">
            Configure where each ticker pulls data from.
          </p>
        </.link>

        <.link
          navigate={~p"/tickers"}
          class="rounded-[1.5rem] border border-base-300 bg-base-100 px-5 py-4 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md"
        >
          <p class="text-xs font-semibold uppercase tracking-[0.24em] text-base-content/45">Manage</p>
          <p class="mt-2 text-lg font-semibold text-base-content">Tickers</p>
          <p class="mt-1 text-sm text-base-content/65">
            Add new tracked symbols or reassign their source.
          </p>
        </.link>

        <.link
          navigate={~p"/news-articles"}
          class="rounded-[1.5rem] border border-base-300 bg-base-100 px-5 py-4 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md"
        >
          <p class="text-xs font-semibold uppercase tracking-[0.24em] text-base-content/45">Browse</p>
          <p class="mt-2 text-lg font-semibold text-base-content">World News</p>
          <p class="mt-1 text-sm text-base-content/65">
            Global headlines from your configured news sources.
          </p>
        </.link>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def handle_info({:prices_updated, prices}, socket) do
    {:noreply,
     socket
     |> assign(:groups, grouped_prices(prices))
     |> assign(:last_updated_at, last_updated_at(prices))}
  end

  @impl true
  def handle_info({:news_updated, _source_slug}, socket) do
    articles = News.list_news_articles(limit: @news_limit)
    {:noreply, stream(socket, :news_articles, articles, reset: true)}
  end

  defp grouped_prices(prices) do
    price_map = Map.new(prices, &{&1.symbol, &1})

    Enum.map(@groups, fn group ->
      rows =
        Enum.map(
          group.symbols,
          &Map.get(price_map, &1, %{symbol: &1, name: &1, price: nil, fetched_at: nil})
        )

      Map.put(group, :rows, rows)
    end)
  end

  defp last_updated_at([]), do: nil

  defp last_updated_at(prices) do
    prices
    |> Enum.max_by(& &1.fetched_at, DateTime)
    |> Map.fetch!(:fetched_at)
  end

  defp format_timestamp(nil), do: "Awaiting first poll"
  defp format_timestamp(datetime), do: Calendar.strftime(datetime, "%Y-%m-%d %H:%M UTC")

  defp format_date(nil), do: ""
  defp format_date(dt), do: Calendar.strftime(dt, "%b %d")
end
