defmodule WorldTrackerWeb.ArticleComponents do
  @moduledoc """
  Reusable UI components for rendering news articles.

  Provides a single `article_card/1` component with two display modes:

    * `:small` — compact card used on the dashboard. Shows a square thumbnail,
      source name, date, and a two-line title. The whole card is a link to the
      external article URL.

    * `:full` — rich card used on the `/news-articles` listing. Shows an
      aspect-video thumbnail, source badge, date, title, description (rendered
      as raw HTML to preserve RSS feed markup), category pills, author, and a
      "Read more" link.
  """

  use Phoenix.Component

  import Phoenix.HTML, only: [raw: 1]

  attr :id, :string, default: nil, doc: "DOM id, required when used inside a LiveView stream"
  attr :article, :map, required: true, doc: "Article struct with preloaded :data_source"
  attr :mode, :atom, default: :full, values: [:small, :full], doc: "Rendering mode"

  def article_card(%{mode: :small} = assigns) do
    ~H"""
    <a
      id={@id}
      href={@article.url}
      target="_blank"
      rel="noopener noreferrer"
      class="group flex gap-3 rounded-[1.25rem] border border-base-300 bg-base-100 p-4 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md"
    >
      <%!-- Square thumbnail --%>
      <div
        :if={@article.image_url}
        class="h-16 w-16 shrink-0 overflow-hidden rounded-xl bg-base-200"
      >
        <img
          src={@article.image_url}
          alt=""
          class="h-full w-full object-cover"
          loading="lazy"
        />
      </div>

      <div class="flex min-w-0 flex-col gap-1">
        <%!-- Source + date --%>
        <div class="flex items-center gap-2">
          <span class="text-xs font-semibold uppercase tracking-wide text-base-content/50">
            {@article.data_source.name}
          </span>
          <span :if={@article.published_at} class="text-xs text-base-content/35 tabular-nums">
            {format_date_short(@article.published_at)}
          </span>
        </div>

        <%!-- Title --%>
        <p class="line-clamp-2 text-sm font-medium leading-snug text-base-content transition-colors group-hover:text-primary">
          {@article.title}
        </p>
      </div>
    </a>
    """
  end

  def article_card(%{mode: :full} = assigns) do
    ~H"""
    <article
      id={@id}
      class="group flex flex-col overflow-hidden rounded-[1.5rem] border border-base-300 bg-base-100 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
    >
      <%!-- Aspect-video thumbnail --%>
      <div :if={@article.image_url} class="aspect-video overflow-hidden bg-base-200">
        <img
          src={@article.image_url}
          alt={@article.title}
          class="h-full w-full object-cover transition group-hover:scale-105"
          loading="lazy"
        />
      </div>

      <div class="flex flex-1 flex-col gap-3 p-5">
        <%!-- Source badge + date --%>
        <div class="flex items-center justify-between gap-2">
          <span class="rounded-full bg-base-200 px-2.5 py-0.5 text-xs font-semibold uppercase tracking-wide text-base-content/70">
            {@article.data_source.name}
          </span>
          <time
            :if={@article.published_at}
            datetime={DateTime.to_iso8601(@article.published_at)}
            class="text-xs text-base-content/45 tabular-nums"
          >
            {format_date_long(@article.published_at)}
          </time>
        </div>

        <%!-- Title --%>
        <h2 class="line-clamp-3 text-base font-semibold leading-snug text-base-content transition-colors group-hover:text-primary">
          <a href={@article.url} target="_blank" rel="noopener noreferrer">
            {@article.title}
          </a>
        </h2>

        <%!-- Description — rendered as raw HTML to preserve RSS feed markup --%>
        <div
          :if={@article.description}
          class="article-description line-clamp-3 flex-1 text-sm leading-relaxed text-base-content/65 [&_a]:underline [&_a]:hover:text-primary"
        >
          {raw(@article.description)}
        </div>

        <%!-- Category pills — up to 3 --%>
        <div :if={@article.categories != []} class="mt-auto flex flex-wrap gap-1.5 pt-2">
          <span
            :for={cat <- Enum.take(@article.categories, 3)}
            class="rounded bg-base-200 px-2 py-0.5 text-xs text-base-content/60"
          >
            {cat}
          </span>
        </div>

        <%!-- Footer: author + read more --%>
        <div class="mt-1 flex items-center justify-between gap-2 border-t border-base-200 pt-3">
          <span :if={@article.author} class="truncate text-xs text-base-content/50">
            {@article.author}
          </span>
          <a
            href={@article.url}
            target="_blank"
            rel="noopener noreferrer"
            class="ml-auto flex shrink-0 items-center gap-1 text-xs font-medium text-primary hover:underline"
          >
            Read more <span class="hero-arrow-top-right-on-square size-3" />
          </a>
        </div>
      </div>
    </article>
    """
  end

  defp format_date_short(nil), do: ""
  defp format_date_short(dt), do: Calendar.strftime(dt, "%b %d")

  defp format_date_long(nil), do: ""
  defp format_date_long(dt), do: Calendar.strftime(dt, "%b %d, %Y")
end
