defmodule WorldTrackerWeb.ArticleLive.Index do
  use WorldTrackerWeb, :live_view

  alias WorldTracker.News
  alias WorldTracker.News.FetchNewsWorker
  alias WorldTracker.Sources

  @articles_per_page 6

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WorldTracker.PubSub, News.topic())
    end

    {:ok,
     socket
     |> assign(:page_title, "World News")
     |> assign(:sources, source_filters())
     |> assign(:active_source, nil)
     |> assign(:page, 1)
     |> assign(:per_page, @articles_per_page)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    source_slug = params["source"]
    page = parse_page(params["page"])
    per_page = socket.assigns.per_page
    offset = (page - 1) * per_page

    articles = News.list_news_articles(source: source_slug, limit: per_page, offset: offset)
    total_count = News.count_news_articles(source: source_slug)
    total_pages = max(ceil(total_count / per_page), 1)

    {:noreply,
     socket
     |> assign(:sources, source_filters())
     |> assign(:active_source, source_slug)
     |> assign(:page, page)
     |> assign(:total_pages, total_pages)
     |> assign(:total_count, total_count)
     |> assign(:articles_empty?, articles == [])
     |> stream(:news_articles, articles, reset: true)}
  end

  defp parse_page(nil), do: 1

  defp parse_page(page) when is_binary(page) do
    case Integer.parse(page) do
      {num, _} when num > 0 -> num
      _ -> 1
    end
  end

  defp parse_page(_), do: 1

  @impl true
  def handle_info({:news_updated, _source_slug}, socket) do
    source_slug = socket.assigns.active_source
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    offset = (page - 1) * per_page

    articles = News.list_news_articles(source: source_slug, limit: per_page, offset: offset)
    total_count = News.count_news_articles(source: source_slug)
    total_pages = max(ceil(total_count / per_page), 1)

    {:noreply,
     socket
     |> assign(:sources, source_filters())
     |> assign(:total_pages, total_pages)
     |> assign(:total_count, total_count)
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

      <%!-- Pagination controls --%>
      <div
        :if={@total_pages > 1}
        class="flex items-center justify-between border-t border-base-300 bg-base-100 px-4 py-3 sm:px-6"
      >
        <div class="flex flex-1 justify-between sm:hidden">
          <.link
            :if={@page > 1}
            patch={pagination_path(@active_source, @page - 1)}
            class="relative inline-flex items-center rounded-md border border-base-300 bg-base-100 px-4 py-2 text-sm font-medium text-base-content hover:bg-base-200"
          >
            Previous
          </.link>
          <.link
            :if={@page < @total_pages}
            patch={pagination_path(@active_source, @page + 1)}
            class="relative ml-3 inline-flex items-center rounded-md border border-base-300 bg-base-100 px-4 py-2 text-sm font-medium text-base-content hover:bg-base-200"
          >
            Next
          </.link>
        </div>
        <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-base-content/70">
              Showing <span class="font-medium">{(@page - 1) * @per_page + 1}</span>
              to <span class="font-medium">{min(@page * @per_page, @total_count)}</span>
              of <span class="font-medium">{@total_count}</span>
              results
            </p>
          </div>
          <div>
            <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
              <.link
                :if={@page > 1}
                patch={pagination_path(@active_source, @page - 1)}
                class="relative inline-flex items-center rounded-l-md px-2 py-2 text-base-content/70 ring-1 ring-inset ring-base-300 hover:bg-base-200 focus:z-20 focus:outline-offset-0"
              >
                <span class="sr-only">Previous</span>
                <.icon name="hero-chevron-left" class="h-5 w-5" />
              </.link>

              <%= for page_num <- pagination_range(@page, @total_pages) do %>
                <.link
                  patch={pagination_path(@active_source, page_num)}
                  class={[
                    "relative inline-flex items-center px-4 py-2 text-sm font-semibold ring-1 ring-inset ring-base-300 focus:z-20 focus:outline-offset-0",
                    if(page_num == @page,
                      do: "z-10 bg-primary text-primary-content focus:bg-primary",
                      else: "text-base-content/70 hover:bg-base-200"
                    )
                  ]}
                >
                  {page_num}
                </.link>
              <% end %>

              <.link
                :if={@page < @total_pages}
                patch={pagination_path(@active_source, @page + 1)}
                class="relative inline-flex items-center rounded-r-md px-2 py-2 text-base-content/70 ring-1 ring-inset ring-base-300 hover:bg-base-200 focus:z-20 focus:outline-offset-0"
              >
                <span class="sr-only">Next</span>
                <.icon name="hero-chevron-right" class="h-5 w-5" />
              </.link>
            </nav>
          </div>
        </div>
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

  defp pagination_path(source_slug, page) do
    if source_slug do
      ~p"/news-articles?source=#{source_slug}&page=#{page}"
    else
      ~p"/news-articles?page=#{page}"
    end
  end

  defp pagination_range(current_page, total_pages) do
    cond do
      total_pages <= 7 ->
        Enum.to_list(1..total_pages)

      current_page <= 3 ->
        Enum.to_list(1..5) ++ [total_pages - 1, total_pages]

      current_page >= total_pages - 2 ->
        [1, 2] ++ Enum.to_list((total_pages - 4)..total_pages)

      true ->
        [1, 2] ++
          Enum.to_list((current_page - 1)..(current_page + 1)) ++ [total_pages - 1, total_pages]
    end
  end
end
