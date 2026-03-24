defmodule WorldTrackerWeb.ArticleLive.Index do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.News
  alias WorldTracker.News.FetchNewsWorker
  alias WorldTracker.Sources

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WorldTracker.PubSub, News.topic())
    end

    articles = News.list_news_articles()

    {:ok,
     socket
     |> assign(:page_title, "World News")
     |> assign(:sources, source_filters())
     |> assign(:active_source, nil)
     |> assign(:articles_empty?, articles == [])
     |> stream(:news_articles, articles)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    source_slug = params["source"]
    articles = News.list_news_articles(source: source_slug)

    {:noreply,
     socket
     |> assign(:sources, source_filters())
     |> assign(:active_source, source_slug)
     |> assign(:articles_empty?, articles == [])
     |> stream(:news_articles, articles, reset: true)}
  end

  @impl true
  def handle_info({:news_updated, _source_slug}, socket) do
    articles = News.list_news_articles(source: socket.assigns.active_source)

    {:noreply,
     socket
     |> assign(:sources, source_filters())
     |> assign(:articles_empty?, articles == [])
     |> stream(:news_articles, articles, reset: true)}
  end

  @impl true
  def handle_event("fetch_all", _params, socket) do
    case FetchNewsWorker.enqueue() do
      {:ok, _job} ->
        {:noreply, put_flash(socket, :info, "Queued a refresh for all news sources")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Unable to queue refresh: #{inspect(reason)}")}
    end
  end

  def handle_event("fetch_source", %{"slug" => slug}, socket) do
    case FetchNewsWorker.enqueue(%{source_slug: slug}) do
      {:ok, _job} ->
        {:noreply, put_flash(socket, :info, "Queued a refresh for #{source_name(slug)}")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Unable to queue refresh: #{inspect(reason)}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <%!-- Hero header --%>
      <section class="relative overflow-hidden rounded-[2rem] border border-base-300 bg-[radial-gradient(circle_at_top_left,_rgba(56,189,248,0.18),_transparent_32%),linear-gradient(135deg,_rgba(15,23,42,0.98),_rgba(30,41,59,0.92))] px-6 py-10 text-base-100 shadow-2xl shadow-slate-950/15 sm:px-10">
        <div class="absolute inset-y-0 right-0 w-1/2 bg-[radial-gradient(circle_at_center,_rgba(251,191,36,0.10),_transparent_58%)]" />
        <div class="relative flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div class="max-w-2xl space-y-4">
            <p class="text-xs font-semibold uppercase tracking-[0.35em] text-sky-300/80">
              World News
            </p>
            <h1 class="font-serif text-4xl leading-tight text-white sm:text-5xl">
              Global headlines, live.
            </h1>
            <p class="max-w-xl text-sm leading-7 text-slate-200/78 sm:text-base">
              Aggregated from your configured news sources and refreshed every 15 minutes.
            </p>
          </div>

          <div class="flex flex-wrap gap-3">
            <.button id="fetch-all-news" variant="primary" phx-click="fetch_all">
              <.icon name="hero-arrow-path" class="size-4" /> Refresh all sources
            </.button>
          </div>
        </div>
      </section>

      <%!-- Source filter tabs --%>
      <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <nav class="flex flex-wrap gap-2" id="source-tabs">
          <.link
            :for={source <- @sources}
            patch={
              if source.slug, do: ~p"/news-articles?source=#{source.slug}", else: ~p"/news-articles"
            }
            class={[
              "rounded-full border px-4 py-1.5 text-sm font-medium transition",
              if(@active_source == source.slug,
                do: "border-primary bg-primary text-primary-content shadow",
                else:
                  "border-base-300 bg-base-100 text-base-content hover:border-primary/50 hover:bg-base-200"
              )
            ]}
          >
            {source.label}
          </.link>
        </nav>

        <div class="flex flex-wrap gap-2" id="source-refresh-controls">
          <button
            :for={source <- Enum.filter(@sources, & &1.slug)}
            id={"fetch-source-#{source.slug}"}
            type="button"
            phx-click="fetch_source"
            phx-value-slug={source.slug}
            class="inline-flex items-center gap-2 rounded-full border border-base-300 bg-base-100 px-3 py-1.5 text-xs font-semibold uppercase tracking-[0.18em] text-base-content/65 transition hover:border-primary/50 hover:text-primary"
          >
            <.icon name="hero-arrow-path" class="size-3.5" /> {source.label}
          </button>
        </div>
      </div>

      <%!-- Empty state (tracked separately from stream) --%>
      <div
        :if={@articles_empty?}
        id="news-empty-state"
        class="py-20 text-center text-base-content/50"
      >
        No articles yet — check back shortly after the first fetch.
      </div>

      <%!-- Article cards --%>
      <div id="news_articles" phx-update="stream" class="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
        <.article_card
          :for={{dom_id, article} <- @streams.news_articles}
          id={dom_id}
          article={article}
        />
      </div>
    </Layouts.app>
    """
  end

  defp source_filters do
    [
      %{slug: nil, label: "All Sources"}
      | Enum.map(Sources.list_news_data_sources(), &source_filter/1)
    ]
  end

  defp source_filter(data_source) do
    %{slug: data_source.slug, label: data_source.name}
  end

  defp source_name(slug) do
    case Enum.find(source_filters(), &(&1.slug == slug)) do
      %{label: label} -> label
      nil -> slug
    end
  end
end
