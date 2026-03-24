defmodule WorldTrackerWeb.ArticleLive.Index do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.News

  @sources [
    %{slug: nil, label: "All Sources"},
    %{slug: "bbc_news", label: "BBC News"},
    %{slug: "al_jazeera", label: "Al Jazeera"},
    %{slug: "the_guardian", label: "The Guardian"},
    %{slug: "npr_world", label: "NPR World"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WorldTracker.PubSub, News.topic())
    end

    articles = News.list_news_articles()

    {:ok,
     socket
     |> assign(:page_title, "World News")
     |> assign(:sources, @sources)
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
     |> assign(:active_source, source_slug)
     |> assign(:articles_empty?, articles == [])
     |> stream(:news_articles, articles, reset: true)}
  end

  @impl true
  def handle_info({:news_updated, _source_slug}, socket) do
    articles = News.list_news_articles(source: socket.assigns.active_source)

    {:noreply,
     socket
     |> assign(:articles_empty?, articles == [])
     |> stream(:news_articles, articles, reset: true)}
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
              Aggregated from BBC News, Al Jazeera, The Guardian, and NPR World — refreshed every 15 minutes.
            </p>
          </div>
        </div>
      </section>

      <%!-- Source filter tabs --%>
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
        <article
          :for={{dom_id, article} <- @streams.news_articles}
          id={dom_id}
          class="group flex flex-col overflow-hidden rounded-[1.5rem] border border-base-300 bg-base-100 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
        >
          <%!-- Thumbnail --%>
          <div :if={article.image_url} class="aspect-video overflow-hidden bg-base-200">
            <img
              src={article.image_url}
              alt={article.title}
              class="h-full w-full object-cover transition group-hover:scale-105"
              loading="lazy"
            />
          </div>

          <div class="flex flex-1 flex-col gap-3 p-5">
            <%!-- Source badge + date --%>
            <div class="flex items-center justify-between gap-2">
              <span class="rounded-full bg-base-200 px-2.5 py-0.5 text-xs font-semibold uppercase tracking-wide text-base-content/70">
                {article.data_source.name}
              </span>
              <time
                :if={article.published_at}
                datetime={DateTime.to_iso8601(article.published_at)}
                class="text-xs text-base-content/45 tabular-nums"
              >
                {format_date(article.published_at)}
              </time>
            </div>

            <%!-- Title --%>
            <h2 class="line-clamp-3 text-base font-semibold leading-snug text-base-content transition-colors group-hover:text-primary">
              <a href={article.url} target="_blank" rel="noopener noreferrer">
                {article.title}
              </a>
            </h2>

            <%!-- Description --%>
            <p
              :if={article.description}
              class="line-clamp-3 flex-1 text-sm leading-relaxed text-base-content/65"
            >
              {article.description}
            </p>

            <%!-- Categories --%>
            <div :if={article.categories != []} class="mt-auto flex flex-wrap gap-1.5 pt-2">
              <span
                :for={cat <- Enum.take(article.categories, 3)}
                class="rounded bg-base-200 px-2 py-0.5 text-xs text-base-content/60"
              >
                {cat}
              </span>
            </div>

            <%!-- Footer: author + read more --%>
            <div class="mt-1 flex items-center justify-between gap-2 border-t border-base-200 pt-3">
              <span :if={article.author} class="truncate text-xs text-base-content/50">
                {article.author}
              </span>
              <a
                href={article.url}
                target="_blank"
                rel="noopener noreferrer"
                class="ml-auto flex shrink-0 items-center gap-1 text-xs font-medium text-primary hover:underline"
              >
                Read more <.icon name="hero-arrow-top-right-on-square" class="w-3 h-3" />
              </a>
            </div>
          </div>
        </article>
      </div>
    </Layouts.app>
    """
  end

  defp format_date(nil), do: ""
  defp format_date(dt), do: Calendar.strftime(dt, "%b %d, %Y")
end
